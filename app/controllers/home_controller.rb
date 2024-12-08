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
        data = Date.parse(zi.date.to_s)
        is_winter_time = data < last_sunday_of_march(data.year) || data >= last_sunday_of_october(data.year)
      
        # Calculăm ora1 și ora2 în GMT
        ora1_gmt = (Time.parse(@ora_inceput) - (is_winter_time ? 2.hours : 3.hours)).strftime('%H:%M:%S')
        ora2_gmt = (Time.parse(@ora_sfarsit) - (is_winter_time ? 2.hours : 3.hours)).strftime('%H:%M:%S')
      
        # Filtrăm datele pentru ziua respectivă și intervalul calculat
        interval = Us30
                     .where(date: zi.date)
                     .where("timestamp::time >= ? AND timestamp::time <= ?", ora1_gmt, ora2_gmt)
                     .select("MIN(low) as min_low, MAX(high) as max_high") # Eliminăm ORDER BY
                     .take # .take înlocuiește .first pentru a evita clauza ORDER BY
      
        {
          date: zi.date,
          min_low: interval.min_low,
          max_high: interval.max_high,
          ora_inceput: ora1_gmt,
          ora_sfarsit: ora2_gmt
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
  
      # Conversie în interval pentru query
      start_time = ora_inceput.strftime('%H:%M:%S')
      end_time = ora_sfarsit.strftime('%H:%M:%S')
  
      # Grupare pe zile și filtrare pe interval orar
      @rezultate = Btc
                     .where("timestamp::time >= ? AND timestamp::time <= ?", start_time, end_time)
                     .select("date, MIN(low) as min_low, MAX(high) as max_high")
                     .group(:date)
                     .order(:date)
    end
  
    # Render către view
    render :analiza_btc_tabel
  end
  

  private

# Funcții pentru calcularea ultimei duminici din martie și octombrie
def last_sunday_of_march(year)
  Date.new(year, 3, 31) - (Date.new(year, 3, 31).wday + 1).days
end

def last_sunday_of_october(year)
  Date.new(year, 10, 31) - (Date.new(year, 10, 31).wday + 1).days
end
end
