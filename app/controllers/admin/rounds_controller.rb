class Admin::RoundsController < Admin::BaseController
  def index
    authorize Round, :admin_index?
    @rounds = Round.order(:position).all
  end

  def create
    authorize Round
    access_database.import_round!
    redirect_to admin_rounds_path
  end

  def show
    @round = Round.find params[:id]
    authorize @round
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
    access_database.import_dance_rounds!(@round) unless @round.round_type.no_dance
    @round.start!
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

  def download_ratings
    ## try catch if file does not exist is missing
    @round = Round.find params[:id]
    send_file Rails.root.join(Rails.root.join('tmp',"T#{@round.tournament_number}_RT#{@round.rt_id}.txt"))
  end

end
