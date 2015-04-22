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
    if dance_round_params[:dance_ratings]
      dance_round_params[:dance_ratings].each do |attributes|
        current_dance_round.dance_ratings.build attributes.merge(user_id: current_user.id)
      end
    end
    acrobatics = []
    if dance_round_params[:acrobatic_ratings]
      dance_round_params[:acrobatic_ratings].each do |attributes|
        acrobatic = current_dance_round.acrobatics.find(attributes[:acrobatic_id])
        acrobatic.acrobatic_ratings.build attributes.merge(user_id: current_user.id)
        acrobatics << acrobatic
      end
    end
    current_dance_round.save!
    acrobatics.each(&:save!)
    judge_dance_teams
  end

  def accept
    authorize current_dance_round
    current_dance_round.close!
    redirect_to judge_dance_round_path
  end

  private

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
      @attributes[:dance_ratings].map! { |attr| attr.permit(policy(@dance_round).permitted_attributes) }
    end
    if @attributes.has_key?(:acrobatic_ratings)
      @attributes[:acrobatic_ratings].map! { |attr| attr.permit(policy(@dance_round).permitted_attributes) }
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
      if current_user.rated?(current_dance_round)
        @ratings = {}
        (current_dance_round.dance_judges << current_user).each do |judge|
          @ratings[judge.id] = current_dance_round.dance_ratings.where(user_id: judge.id).all.group_by(&:dance_team_id)
        end
        @acrobatic_ratings = {}
        current_dance_round.acrobatics_judges.each do |judge|
          @acrobatic_ratings[judge.id] = {}
          current_dance_round.acrobatics.each do |acrobatic|
            @acrobatic_ratings[judge.id][acrobatic.id] = {}
            @acrobatic_ratings[judge.id][acrobatic.id] = acrobatic.acrobatic_ratings.where(user_id: judge.id).all.group_by(&:dance_team_id)
          end
        end
        if request.xhr?
          render :json, still_waiting: true, body: render_to_string(partial: :accept_tables)
        else
          render :accept
        end
      else
        render :recognize_failures_only
      end
    else
      @dance_round = DanceRound.where(started: false).order(:position).first
      render :start_dance_round
    end
  end

  def judge(judgment_type)
    if current_dance_round
      if current_user.rated?(current_dance_round)
        if request.xhr?
          render :json, still_waiting: true, body: render_to_string(partial: :waiting_table)
        else
          render :wait_for_ending
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
