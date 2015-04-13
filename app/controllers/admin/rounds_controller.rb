class Admin::RoundsController < Admin::BaseController
  def index
    authorize Round, :admin_index?
    @rounds = Round.order(:position).all
  end

  def create
    authorize Round, :create?
    access_database.import_round!
    redirect_to admin_rounds_path
  end

  def edit
    @round = Round.find params[:id]
    authorize @round
  end

  def update
    @round = Round.find params[:id]
    authorize @round
    params[:judges].split(',').each_with_index do |judge_id, index|
      @judge = User.find judge_id
      @judge.add_role Round.judge_role_for(index), @round
    end
    redirect_to admin_rounds_path
  end

  def start
    @round = Round.find params[:id]
    authorize @round
    @round.start!
    access_database.import_dance_rounds!(@round) unless @round.round_type.no_dance
    redirect_to admin_rounds_path
  end

  def close
    @round = Round.find params[:id]
    authorize @round
    @round.close!
    redirect_to admin_rounds_path
  end

  def destroy
    @round = Round.find params[:id]
    authorize @round
    @round.destroy
    redirect_to admin_rounds_path
  end

end
