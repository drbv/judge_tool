class Judges::DanceRoundsController < Judges::BaseController

  helper_method :current_round, :current_dance_round

  def show
    authorize DanceRound
    if current_round
      if current_round.round_type.no_dance
        render :no_dance_round
      else
        judge_dance_teams
      end
    else
      render :no_active_round
    end
  end

  def create
    @dance_round = DanceRound.next
    authorize @dance_round
    @dance_round.start!
    redirect_to judges_dance_round_path
  end

  def update
    authorize current_dance_round
    set_dance_ratings
    acrobatics = set_acrobatics_ratings
    current_dance_round.save!
    acrobatics.each(&:save!)
    judge_dance_teams
  end

  def accept
    authorize current_dance_round
    adjust_mistakes
    adjust_acrobatic_mistakes
    if reopen?
      reopen!
    else
      close!
    end
    redirect_to judges_dance_round_path
  end

  private

  def reopen?
    reopen_flags.any? { |value| value == '1' }
  end

  def reopen_flags
    params[:reopen].values.flatten.map(&:values).flatten.map(&:values).flatten.map(&:values).flatten +
      params[:reopen_acrobatic].values.flatten.map(&:values).flatten.map(&:values).flatten
  end

  def reopen!
    reopen_dance_ratings!
    reopen_acrobatic_ratings!
  end

  def reopen_acrobatic_ratings!
    params[:reopen_acrobatic].each do |judge_id, acrobatics|
      acrobatics.each do |acrobatic_id, reopen|
        acrobatic_rating = current_dance_round.acrobatic_ratings.where(user_id: judge_id, acrobatic_id: acrobatic_id)
        acrobatic_rating.reopen! :rating if reopen == '1'
      end
    end
  end

  def reopen_dance_ratings!
    params[:reopen].each do |judge_id, dance_teams_attributes|
      dance_teams_attributes.each do |dance_team_id, attributes|
        dance_rating = current_dance_round.dance_ratings.find_by(user_id: judge_id, dance_team_id: dance_team_id)
        reopen_attributes = []
        attributes.each do |attribute, reopen|
          reopen_attributes << attribute if reopen == '1'
        end
        dance_rating.reopen! reopen_attributes
      end
    end
  end

  def close!
    current_user.dance_ratings.where(dance_round_id: current_dance_round.id).each do |rating|
      rating.final!
    end
    if current_dance_round.dance_ratings.where(user_id: current_round.observers.map(&:id)).all?(&:final?)
      current_dance_round.close!
      current_dance_round.round.close! unless DanceRound.next
    end
  end

  def adjust_mistakes
    return unless params[:adjusted]
    params[:adjusted].each do |dance_team_id, updated_mistakes|
      current_dance_round.dance_ratings.where(dance_team_id: dance_team_id).update_all mistakes: updated_mistakes
    end
  end

  def adjust_acrobatic_mistakes
    return unless params[:adjusted_acrobatic]
    params[:adjusted_acrobatic].each do |acrobatic_id, updated_mistakes|
      current_dance_round.acrobatics.find(acrobatic_id).update_all mistakes: updated_mistakes
    end
  end

  def set_dance_ratings
    if dance_round_params[:dance_ratings]
      dance_round_params[:dance_ratings].each do |attributes|
        current_dance_round.dance_ratings.build attributes.merge(user_id: current_user.id)
      end
    end
  end

  def set_acrobatics_ratings
    acrobatics = []
    if dance_round_params[:acrobatic_ratings]
      dance_round_params[:acrobatic_ratings].each do |attributes|
        acrobatic = current_dance_round.acrobatics.find(attributes[:acrobatic_id])
        acrobatic.acrobatic_ratings.build attributes.merge(user_id: current_user.id)
        acrobatics << acrobatic
      end
    end
    acrobatics
  end

  def redirect_to_login
    if params[:action] == 'show'
      super
    else
      redirect_to judges_dance_round_path
    end
  end

  def dance_round_params
    @attributes = params.require(:dance_round)
    if @attributes.has_key?(:dance_ratings)
      @attributes[:dance_ratings].map! { |attr| attr.permit(policy(@dance_round).permitted_dance_attributes) }
    end
    if @attributes.has_key?(:acrobatic_ratings)
      @attributes[:acrobatic_ratings].map! { |attr| attr.permit(policy(@dance_round).permitted_acrobatic_attributes) }
    end
    @attributes
  end

  def judge_dance_teams
    if current_user.has_role?(:observer, current_round)
      observe_judgments
    elsif current_user.has_role?(:dance_judge, current_round)
      judge :dance_technique
    elsif current_user.has_role?(:acrobatics_judge, current_round)
      judge :acrobatics
    else
      render :pause
    end
  end

  def observe_judgments
    if current_dance_round
      if current_user.has_to_rate?(current_dance_round)
        if current_user.rated?(current_dance_round)
          evaluate_ratings
        else
          render :recognize_failures_only
        end
      else
        render :waiting_observer
      end
    else
      @dance_round = current_round.dance_rounds.where(started: false).order(:position).first
      render :start_dance_round
    end
  end

  def evaluate_ratings
    if current_dance_round.accepted_by?(current_user)
      render :waiting_observer
    else
      ratings_overview
      if request.xhr?
        render :json, still_waiting: true, body: render_to_string(partial: 'accept_tables')
      else
        render :accept
      end
    end
  end

  def ratings_overview
    @ratings = {}
    (current_dance_round.dance_judges << current_user).each do |judge|
      @ratings[judge.id] = current_dance_round.dance_ratings.validating(current_user, judge, current_dance_round).to_a.group_by(&:dance_team_id)
    end
    @acrobatic_ratings = {}
    (current_dance_round.acrobatics_judges << current_user).each do |judge|
      @acrobatic_ratings[judge.id] = {}
      current_dance_round.acrobatics.each do |acrobatic|
        @acrobatic_ratings[judge.id][acrobatic.id] = acrobatic.acrobatic_ratings.validating(current_user, judge, current_dance_round).to_a.group_by(&:dance_team_id)
      end
    end
  end

  def judge(judgment_type)
    if current_dance_round
      if current_user.rated?(current_dance_round)
        if current_user.open_discussion?(current_dance_round)
          render :"update_#{judgment_type}_rating"
        else
          if request.xhr?
            render :json, still_waiting: true, body: render_to_string(partial: 'waiting_table')
          else
            render :wait_for_ending
          end
        end
      else
        render :"judge_#{judgment_type}"
      end
    else
      render :no_dance_round
    end
  end

  def current_round
    @round ||= Round.active
  end

  def current_dance_round
    @dance_round ||= DanceRound.active
  end
end
