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
    authorize current_dance_round
    current_dance_round.start!
    redirect_to judges_dance_round_path
  end

  def update
    authorize current_dance_round
    %i(dance_ratings acrobatic_ratings).each do |rating_type|
      if dance_round_params[rating_type]
        dance_round_params[rating_type].each do |attributes|
          current_dance_round.dance_ratings.build attributes.merge(user_id: current_user.id)
        end
      end
    end
    current_dance_round.save
    judge_dance_teams
  end

  def accept
    authorize current_dance_round
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
      judge_dance_technique
    elsif current_user.has_role?(:acrobatics_judge, current_round)
      judge_acrobatics
    else
      render :pause
    end
  end

  def observe_judgments
    if current_dance_round
      if current_user.rated?(current_dance_round)
        render :accept
      else
        render :recognize_failures_only
      end
    else
      @dance_round = DanceRound.where(started: false).order(:position).first
      render :start_dance_round
    end
  end

  def judge_dance_technique
    if current_dance_round
      if current_user.rated?(current_dance_round)
        render :wait_for_ending
      else
        render :judge_dance_technique
      end
    else
      render :no_dance_round
    end
  end

  def judge_acrobatics
    if current_dance_round
      if current_user.rated?(current_dance_round)
        render :wait_for_ending
      else
        render :judge_acrobatics
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
