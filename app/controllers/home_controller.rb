class HomeController < ApplicationController
  def index
  end
  def preluare
  end  
  def analiza_us30
    # Variabile inițiale (opțional)
    @ora_inceput = nil
    @ora_sfarsit = nil
  end

  def analiza_us30_tabel
    if request.get?
      # Setare implicită pentru acces direct
      @ora_inceput = nil
      @ora_sfarsit = nil
      @rezultate = []
    elsif request.post?
      # Preluarea datelor din formular
      ora_inceput = Time.new(
        params["[ora_inceput(1i)]"].to_i,
        params["[ora_inceput(2i)]"].to_i,
        params["[ora_inceput(3i)]"].to_i,
        params["[ora_inceput(4i)]"].to_i,
        params["[ora_inceput(5i)]"].to_i
      )
  
      ora_sfarsit = Time.new(
        params["[ora_sfarsit(1i)]"].to_i,
        params["[ora_sfarsit(2i)]"].to_i,
        params["[ora_sfarsit(3i)]"].to_i,
        params["[ora_sfarsit(4i)]"].to_i,
        params["[ora_sfarsit(5i)]"].to_i
      )
  
      # Setăm variabilele pentru view
      @ora_inceput = ora_inceput.strftime('%H:%M')
      @ora_sfarsit = ora_sfarsit.strftime('%H:%M')
  
      # Obținem toate zilele distincte din tabel
      zile = Us30.select(:date).distinct.order(:date)
  
      @rezultate = zile.map do |zi|
        # Filtrăm datele pentru ziua respectivă și intervalul calculat
        interval = Us30
                     .where(date: zi.date)
                     .where("timestamp::time >= ? AND timestamp::time <= ?", @ora_inceput, @ora_sfarsit)
                     .select("MIN(low) as min_low, MAX(high) as max_high")
                     .take
  
        {
          date: zi.date,
          min_low: interval&.min_low || "N/A",
          max_high: interval&.max_high || "N/A",
          ora_inceput: @ora_inceput,
          ora_sfarsit: @ora_sfarsit
        }
      end
    end
  
    # Render către view
    render :analiza_us30_tabel
  end
  
  
  def analiza_btc
    # Variabile inițiale
    @ora_inceput = nil
    @ora_sfarsit = nil
  end

  def analiza_btc_tabel
    if request.get?
      # Setare implicită pentru acces direct
      @ora_inceput = nil
      @ora_sfarsit = nil
      @rezultate = []
    elsif request.post?
      # Preluarea datelor din formular
      ora_inceput = Time.new(
        params["[ora_inceput(1i)]"].to_i,
        params["[ora_inceput(2i)]"].to_i,
        params["[ora_inceput(3i)]"].to_i,
        params["[ora_inceput(4i)]"].to_i,
        params["[ora_inceput(5i)]"].to_i
      )
  
      ora_sfarsit = Time.new(
        params["[ora_sfarsit(1i)]"].to_i,
        params["[ora_sfarsit(2i)]"].to_i,
        params["[ora_sfarsit(3i)]"].to_i,
        params["[ora_sfarsit(4i)]"].to_i,
        params["[ora_sfarsit(5i)]"].to_i
      )
  
      # Setăm variabilele pentru view
      @ora_inceput = ora_inceput.strftime('%H:%M')
      @ora_sfarsit = ora_sfarsit.strftime('%H:%M')
  
      # Grupare pe zile și filtrare pe interval orar
      @rezultate = Btc
                     .where("timestamp::time >= ? AND timestamp::time <= ?", @ora_inceput, @ora_sfarsit)
                     .select("date, MIN(low) as min_low, MAX(high) as max_high")
                     .group(:date)
                     .order(:date)
                     .map do |rezultat|
                       {
                         date: rezultat.date,
                         min_low: rezultat.min_low,
                         max_high: rezultat.max_high,
                         ora_inceput: @ora_inceput,
                         ora_sfarsit: @ora_sfarsit
                       }
                     end
    end
  
    # Render către view
    render :analiza_btc_tabel
  end
  
  


end
