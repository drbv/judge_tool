class Judges::DanceRoundsController < Judges::BaseController

  def show
    authorize DanceRound
    if current_round
      if current_round.round_type.no_dance
        render_xhr :no_dance_round
      else
        judge_dance_teams
      end
    else
      render_xhr :no_active_round
    end
  end

  def create
    @dance_round = DanceRound.next
    unless @dance_round.nil?
      authorize @dance_round
      @dance_round.start!

    end
    reload_judges
    reload_beamer
    reload_observer
    redirect_to judges_dance_round_path
  end

  def update
    authorize current_dance_round
    if current_dance_round.reopened?
      update_ratings
    else
      set_dance_ratings
      acrobatics = set_acrobatics_ratings
      current_dance_round.save!
      acrobatics.each(&:save!)
    end
    refresh_judge_statusse
    reload_observer
    judge_dance_teams
  end

  def refresh_judge_statusse
    $judge_status_bars.send render_to_string partial: '/judges/dance_rounds/judge_statusses_all'
  end

  def reload_judges
    $judge_status_bars.send 'reload'
  end

  def reload_observer
    $observer.send 'reload'
  end

  def accept
    authorize current_dance_round
    adjust_mistakes
    adjust_acrobatic_mistakes
    if $show_all_values_to_observer && reopen?
      reopen!
    else
      close!
      reload_beamer
    end
    refresh_judge_statusse
    redirect_to judges_dance_round_path
  end

  def status
    render plain: judge_status_class(User.find(params[:user_id]), DanceRound.find(params[:id]))
  end

  private

  def update_ratings
    @attributes = params.require(:dance_round)
    if @attributes[:dance_ratings]
      @attributes[:dance_ratings].each do |dance_rating_id, attributes|
        rating = DanceRating.find(dance_rating_id)
        next unless rating.reopened?
        rating.update_attributes attributes.permit(policy(@dance_round).permitted_dance_attributes)
        rating.close!
      end
    end
    if @attributes[:acrobatic_ratings]
      @attributes[:acrobatic_ratings].each do |acro_rating_id, attributes|
        rating = AcrobaticRating.find(acro_rating_id)
        next unless rating.reopened?
        rating.update_attributes attributes.permit(policy(@dance_round).permitted_acrobatic_attributes)
        rating.close!
      end
    end
  end

  def reopen?
    reopen_flags.any? { |value| value == '1' }
  end

  def reopen_flags
    params[:reopen].values.flatten.map(&:values).flatten.map(&:values).flatten + reopen_acrobatic_flags
  end

  def reopen_acrobatic_flags
    if params[:reopen_acrobatic]
      params[:reopen_acrobatic].values.flatten.map(&:values).flatten if params[:reopen_acrobatic]
    else
      []
    end
  end

  def reopen!
    reopen_dance_ratings!
    reopen_acrobatic_ratings! unless current_dance_round.round.has_no_acrobatics?
  end

  def reopen_acrobatic_ratings!
    params[:reopen_acrobatic].each do |judge_id, acrobatics|
      acrobatics.each do |acrobatic_id, reopen|
        acrobatic_rating = current_dance_round.acrobatic_ratings.where(user_id: judge_id, acrobatic_id: acrobatic_id).first
        acrobatic_rating.reopen! ['rating'] if reopen == '1'
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
    close_dance_round!
  end

  def close_dance_round!
    if current_dance_round.dance_ratings.where(user_id: current_round.observers.map(&:id)).all?(&:final?)
      current_dance_round.close!
      reload_judges
    end
  end

  def adjust_mistakes
    return unless params[:adjusted]
    params[:adjusted].each do |dance_team_id, updated_mistakes|
      current_dance_round.dance_ratings.where(dance_team_id: dance_team_id).each do |rating|
        rating.update_attributes mistakes: updated_mistakes
      end
    end
  end

  def adjust_acrobatic_mistakes
    return unless params[:adjusted_acrobatic]
    params[:adjusted_acrobatic].each do |acrobatic_id, updated_mistakes|
      current_dance_round.acrobatics.find(acrobatic_id).acrobatic_ratings.each do |rating|
        rating.update_attributes mistakes: updated_mistakes
      end
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
    if params[:action] == 'current_dance_round'
      super
    else
      redirect_to judges_dance_round_path
    end
  end

  def dance_round_params
    @attributes = params.require(:dance_round)
    if @attributes[:dance_ratings].is_a?(Array)
      @attributes[:dance_ratings].map! { |attr| attr.permit(policy(@dance_round).permitted_dance_attributes) }
    end
    if @attributes[:acrobatic_ratings].is_a?(Array)
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
      render_xhr :pause
    end
  end

  def observe_judgments
    if current_dance_round
      if current_user.has_to_rate?(current_dance_round)
        if current_user.rated?(current_dance_round)
          evaluate_ratings
        else
          render_xhr :recognize_failures_only
        end
      else
        render_xhr :pause
      end
    else
      @dance_round = current_round.dance_rounds.where(started: false).order(:position).first
      if @dance_round
        render_xhr :start_dance_round
      else
        render_xhr :no_active_round
      end
    end
  end

  def evaluate_ratings
    if current_dance_round.accepted_by?(current_user)
      close_dance_round!
      render_xhr :wait_for_ending
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
        @acrobatic_ratings[judge.id][acrobatic.id] = acrobatic.acrobatic_ratings.validating(current_user, judge, current_dance_round).first
      end
    end
  end

  def judge(judgment_type)
    if current_dance_round
      if current_user.rated?(current_dance_round)
        if current_user.open_discussion?(current_dance_round)
          render_xhr :"update_#{judgment_type}_rating"
        else
          if request.xhr?
            render :json, still_waiting: true, body: render_to_string(partial: 'waiting_table')
          else
            render :wait_for_ending
          end
        end
      else
        render_xhr :"judge_#{judgment_type}"
      end
    else
      @dance_round = current_round.dance_rounds.where(started: false).order(:position).first
      if @dance_round
        render_xhr :no_dance_round
      else
        render_xhr :no_active_round
      end
    end
  end

end
