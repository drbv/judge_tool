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

  def repeat
    @dance_team = DanceTeam.find params[:dance_team_id]
    @dance_round = DanceRound.find params[:dance_round_id]
    unless @dance_round.round.closed?
      @dance_round_mapping = DanceRoundMapping.find_by(dance_team_id: @dance_team.id, dance_round_id: @dance_round.id)
      @dance_round_mapping.repeat!
      @new_dance_round = DanceRoundMapping.find_by(id: @dance_round_mapping.repeated_mapping_id).dance_round

      unless @dance_round.round.has_no_acrobatics?
        Acrobatic.where(dance_team_id: @dance_team.id, dance_round_id: @dance_round.id).each { |acrobatics| acrobatics.repeat!(@new_dance_round) }
      end
    end
    redirect_to admin_rounds_path
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
    if import_dance_round_from_round(@round)
      @round.start!
    end
    redirect_to admin_rounds_path
  end

  def close
    @round = Round.find params[:id]
    authorize @round
    @round.dance_rounds.map(&:close!)
    @round.close!
    @anchor_name = "r#{@round.id}"
    if Round.next
      @anchor_name = "r#{Round.next.id}"
      if import_dance_round_from_round(Round.next)
        Round.next.start!
      else
        @anchor_name = ''
      end
    end
    redirect_to admin_rounds_path(anchor: @anchor_name)
  end

  def import_dance_round_from_round(round)
    if !round.round_type.no_dance
      if round.judges.count > 0
        if access_database.round_dance_teams_elected?(round)
          if access_database.dance_rounds_available?(round)
            begin
              access_database.import_dance_rounds!(round) unless round.round_type.no_dance
              return true
            rescue => ex
              logger.error ex.message
              flash[:danger]="Fehler beim importieren <br>Error: #{ex.message}"
              return false
            end
          else
            flash[:danger]="Die Runde enthält keine Paare, wenn das beabsichtigt ist muss die Runde aus dem Zeitplan gelöscht werden"
            return false
          end
        else
          flash[:danger]="Als Anwesend markierte Teams/Paare tanzen in keiner Runde. Rundenauslosung prüfen!"
          return false
        end

      else
        #Do not import dance_rounds. Round Type not Suported
        flash[:warning]="Tanzrunden werden nicht importiert, Rundentyp nicht unterstützt"
        @anchor_name=''
        return true
      end
    else
      #Do not import dance_rounds. This Round does not have some
      return true
    end
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
    send_file Rails.root.join(Rails.root.join('tmp','files', "T#{@round.tournament_number}_RT#{@round.rt_id}.txt"))
  end

end
