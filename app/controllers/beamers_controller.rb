class BeamersController < ApplicationController
  def index
    @beamers = Beamer.all
  end

  def show
      beamer = Beamer.find(params[:id])
      if current_round
        if current_round.round_type.no_dance? || current_round.judges.empty?

          if current_round.round_type.name="Siegerehrung"
            @round=Round.where(dance_class_id: current_round.dance_class.id, started: true, closed: true).order(:position).last
            if @round.nil?
              render :round_name, layout: "beamer"
            else
              @dance_team_result_list = get_dance_team_result_list(@round)
              render :round_ceremony, layout: "beamer"
            end
          else
            render :round_name, layout: "beamer"
          end

        else
          if beamer.screen=="moderator"
            @round=current_round
              if @round.dance_rounds.where(round_id: @round.id, started: false, finished: false).count == @round.dance_rounds.count
                @dance_round = DanceRound.where(round_id: @round.id).order(:position).first
                #Es wurde nch keine Tanzrunde gestartet
              elsif current_dance_round
                @dance_round = current_dance_round
                # ich bin in einer tanzrunde

              else
                # Ich bin nach einer Tanzrunde
                @dance_round = DanceRound.where(round_id: @round.id, started: true, finished: true).order(:position).last

              end

            @next_dance_round = DanceRound.where(round_id: @round.id, position: @dance_round.position+1).first

            render :moderator_current, layout: "beamer"


        elsif current_dance_round && (beamer.screen=="current_team" || beamer.screen=="auto")
          render :current_dance_round, layout: "beamer"
        else
          @dance_round = DanceRound.where(round_id: current_round.id, started: true, finished: true).order(:position).last
          if @dance_round
            @round = @dance_round.round
            if beamer.screen=="current_team"
              render :current_dance_round, layout: "beamer"

            elsif @round.round_type.name.include? 'KO'
              render :dance_round_KO, layout: "beamer"
            else
              @dance_team_result_list = @round.dance_teams.uniq.select{|dance_team| dance_team.has_danced?(@round)}.sort_by {|dance_team| dance_team.get_final_result(@round)}.reverse
              render :round_results, layout: "beamer"
            end

          else
            if current_round.dance_rounds.count > 0
              @round=current_round
              @dance_round=@round.dance_rounds.first
              @dance_team_result_list = @round.dance_teams.uniq.select{|dance_team| dance_team.has_danced?(@round)}.sort_by {|dance_team| dance_team.get_final_result(@round)}.reverse
              render :round_results, layout: "beamer"
            else
              render :round_name, layout: "beamer"
            end

          end
        end
        end
      else
        if Round.where(closed: true).count > 0
          render :end_of_tournament, layout: "beamer"
        else
          render :starting_tournament_soon, layout: "beamer"
        end


      end
  end

  def get_dance_team_result_list(round)
    round.dance_teams.uniq.select{|dance_team| dance_team.has_danced?(@round)}.sort_by {|dance_team| dance_team.get_final_result(@round)}.reverse
  end


  def edit
    @beamers = Beamer.find(params[:id])
  end

  def create
    @beamer= Beamer.create screen: "auto"
    redirect_to beamers_path
  end

  def destroy
    Beamer.find(params[:id]).destroy
    redirect_to beamers_path
  end

  def update
    Beamer.find(params[:id]).update_attribute(:screen,params[:screen])
    reload_beamer
    redirect_to(:back)
  end

  def refresh_all
    reload_beamer
    redirect_to beamers_path
  end

  def edit
    @beamer = Beamer.find(params[:id])
    render :remote_control, layout: "beamer"
  end

  private

  def reload_beamer
    $beamer.send 'reload'
  end


end
