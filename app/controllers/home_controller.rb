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
      @ora_inceput = nil
      @ora_sfarsit = nil
      @ora_pivot = nil
      @coeficient = nil
      @rezultate = []
    elsif request.post?
      # Preluare date din formular
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
  
      ora_pivot = Time.new(
        params["[ora_pivot(1i)]"].to_i,
        params["[ora_pivot(2i)]"].to_i,
        params["[ora_pivot(3i)]"].to_i,
        params["[ora_pivot(4i)]"].to_i,
        params["[ora_pivot(5i)]"].to_i
      )
  
      coeficient = params[:coeficient].to_f
  
      # Setăm variabilele pentru view
      @ora_inceput = ora_inceput.strftime('%H:%M')
      @ora_sfarsit = ora_sfarsit.strftime('%H:%M')
      @ora_pivot = ora_pivot.strftime('%H:%M')
      @coeficient = coeficient
  
      # Interogare bază de date și calcul
      @rezultate = Us30
                     .where("timestamp::time >= ? AND timestamp::time <= ?", @ora_inceput, @ora_sfarsit)
                     .select("date, MIN(low) as min_low, MAX(high) as max_high")
                     .group(:date)
                     .order(:date)
                     .map do |rezultat|
        # Calcul valori inițiale
        max_high = rezultat.max_high || 0
        min_low = rezultat.min_low || 0
        adaos = (max_high - min_low) * coeficient
        tp_buy_stop = max_high + adaos
        tp_sell_stop = min_low - adaos
        entry_sell = min_low - 3
        entry_buy = max_high + 3
        sl_sell = max_high + 6
        sl_buy = min_low - 6
  
        # Calcul pentru noile câmpuri
        entry_bx7 = sl_sell
        sl_bx7 = entry_sell
        tp_bx7 = sl_sell + (adaos / 2.5)
        entry_sx7 = sl_buy
        sl_sx7 = entry_buy
        tp_sx7 = sl_buy - (adaos / 2.5)
  
        # Adăugare logică pentru câmpul "Atins"
        atins = "N/A"
        in_process = false
        process_type = nil
  
        Us30.where("date = ?", rezultat.date)
            .where("timestamp::time >= ?", ora_pivot.strftime('%H:%M'))
            .order(:timestamp)
            .each do |row|
          # Logăm valorile analizate pentru debugging
          puts "Analizăm rândul: High=#{row.high}, Low=#{row.low}, EntryB=#{entry_buy}, EntryS=#{entry_sell}"
  
          # Pas 1: Determinăm direcția inițială, dacă nu este stabilită
          if !in_process
            if row.high >= entry_buy
              in_process = true
              process_type = 'buy'
              puts "Direcția stabilită: BUY"
            elsif row.low <= entry_sell
              in_process = true
              process_type = 'sell'
              puts "Direcția stabilită: SELL"
            else
              # Continuăm să analizăm rânduri dacă nu este clară direcția
              puts "Nicio direcție stabilită încă. Continuăm."
              next
            end
          end
  
          # Pas 2: Continuăm analiza pe direcția stabilită
          if process_type == 'buy'
            # Verificăm TP pentru Buy Logic
            if row.high >= tp_buy_stop
              atins = "Buy1"
              puts "Atins: Buy1"
              break
            elsif row.low <= sl_buy
              # Continuăm să căutăm TP sau SL
              if row.high >= tp_sx7
                atins = "Sell2"
                puts "Atins: Sell2"
                break
              elsif row.high <= sl_sx7
                atins = "SL"
                puts "Atins: SL"
                break
              end
            end
          elsif process_type == 'sell'
            # Verificăm TP pentru Sell Logic
            if row.low <= tp_sell_stop
              atins = "Sell1"
              puts "Atins: Sell1"
              break
            elsif row.high >= sl_sell
              # Continuăm să căutăm TP sau SL
              if row.low <= tp_bx7
                atins = "Buy2"
                puts "Atins: Buy2"
                break
              elsif row.low >= sl_bx7
                atins = "SL"
                puts "Atins: SL"
                break
              end
            end
          end
        end
  
        # Rezultatul final pentru ziua curentă
        {
          date: rezultat.date,
          min_low: min_low || "N/A",
          max_high: max_high || "N/A",
          tp_buy_stop: tp_buy_stop || "N/A",
          tp_sell_stop: tp_sell_stop || "N/A",
          entry_sell: entry_sell || "N/A",
          entry_buy: entry_buy || "N/A",
          sl_sell: sl_sell || "N/A",
          sl_buy: sl_buy || "N/A",
          entry_bx7: entry_bx7 || "N/A",
          sl_bx7: sl_bx7 || "N/A",
          tp_bx7: tp_bx7 || "N/A",
          entry_sx7: entry_sx7 || "N/A",
          sl_sx7: sl_sx7 || "N/A",
          tp_sx7: tp_sx7 || "N/A",
          atins: atins
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
