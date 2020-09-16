require 'fuzzystringmatch'

class SymptomsController < ApplicationController
  def search
    if search_params[:symptom].empty? || search_params[:symptom] == ' ' || search_params[:when].empty?
      flash[:error] = 'Please be sure to specify a symptom and when you experienced it'
      redirect_to request.referer
    else
      jarow = FuzzyStringMatch::JaroWinkler.create(:native)
      symptoms = current_user.medications.map do |med|
        med.symptoms.map do |sym|
          sym.description
        end
      end.flatten
      @results = symptoms.select do |symptom|
        jarow.getDistance(search_params[:symptom].downcase, symptom.downcase) >= 0.7
      end

      @results << search_params[:symptom] if @results.empty?

      @log_hash = {when: search_params[:when], note: search_params[:note]}
    end
  end

  private

  def search_params
    params.permit(:symptom, :when, :note)
  end
end