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
      # 1. Preluare date din formular
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
  
      @ora_inceput = ora_inceput.strftime('%H:%M')
      @ora_sfarsit = ora_sfarsit.strftime('%H:%M')
      @ora_pivot = ora_pivot.strftime('%H:%M')
      @coeficient = coeficient
  
      # Prima baleiere: date zilnice agregate
      rezultate_initiale = Us30
        .where("timestamp::time >= ? AND timestamp::time <= ?", @ora_inceput, @ora_sfarsit)
        .select("date, MIN(low) as min_low, MAX(high) as max_high")
        .group(:date)
        .order(:date)
        .map do |rezultat|
          max_high = rezultat.max_high || 0
          min_low = rezultat.min_low || 0
          adaos = (max_high - min_low) * coeficient
          {
            date: rezultat.date,
            min_low: min_low,
            max_high: max_high,
            tp_buy_stop: max_high + adaos,
            tp_sell_stop: min_low - adaos,
            entry_sell: min_low - 3,
            entry_buy: max_high + 3,
            sl_sell: max_high + 6,
            sl_buy: min_low - 6,
            entry_bx7: max_high + 6,
            sl_bx7: (min_low - 3),
            tp_bx7: (max_high + 6) + (adaos / 2.5),
            entry_sx7: (min_low - 6),
            sl_sx7: (max_high + 3),
            tp_sx7: (min_low - 6) - (adaos / 2.5)
          }
        end
  
      if rezultate_initiale.empty?
        @rezultate = []
        render :analiza_us30_tabel and return
      end
  
      # Încărcăm toate datele pe zile
      start_date = rezultate_initiale.first[:date]
      end_date = rezultate_initiale.last[:date]
  
      toate_datele = Us30
        .where("date >= ? AND date <= ?", start_date, end_date)
        .order(:date, :timestamp)
  
      date_pe_zile = {}
      toate_datele.each do |row|
        date_pe_zile[row.date] ||= []
        date_pe_zile[row.date] << row
      end
  
      # Stocăm rezultatele într-un hash pentru a putea modifica ulterior:
      daily_data = {}
      rezultate_initiale.each do |zi|
        daily_data[zi[:date]] = zi.merge({
          atins: "N/A",
          closing_time: "N/A"
        })
      end
  
      # Stare tranzacție multi-zi
      tranzactie_deschisa = false
      process_type = nil
      conditii_initiale = {}
      data_deschidere = nil
  
      # Vom stoca informații despre tranzacția curentă astfel:
      # { start_date: Date, atins: ..., closing_dt: DateTime sau nil daca nu s-a inchis }
      tranzactie_info = {
        start_date: nil,
        atins: nil,
        closing_dt: nil
      }
  
      check_inchidere = lambda do |row, tip, cond|
        closing_dt = DateTime.parse("#{row.date} #{row.timestamp.strftime('%H:%M:%S')}")
        if tip == 'buy'
          if row.high >= cond[:tp_buy_stop]
            return ["Buy1", closing_dt]
          elsif row.low <= cond[:sl_buy]
            if row.high >= cond[:tp_sx7]
              return ["Sell2", closing_dt]
            elsif row.high <= cond[:sl_sx7]
              return ["SL", closing_dt]
            end
          end
        elsif tip == 'sell'
          if row.low <= cond[:tp_sell_stop]
            return ["Sell1", closing_dt]
          elsif row.high >= cond[:sl_sell]
            if row.low <= cond[:tp_bx7]
              return ["Buy2", closing_dt]
            elsif row.low >= cond[:sl_bx7]
              return ["SL", closing_dt]
            end
          end
        end
        return nil
      end
  
      # Faza 1: Analizăm zi cu zi, doar pentru a determina momentul exact al închiderii tranzacțiilor
      (rezultate_initiale.map{|r| r[:date]}).each do |current_date|
        zi = daily_data[current_date]
        minute_curente = date_pe_zile[current_date] || []
  
        if tranzactie_deschisa
          # Avem o tranzacție veche
          inchisa_inainte_pivot = false
          inchisa_dupa_pivot = false
  
          # Încercăm închiderea
          minute_curente.each do |row|
            if row.timestamp.strftime('%H:%M') < @ora_pivot
              rez = check_inchidere.call(row, process_type, conditii_initiale)
              if rez
                # Închisă înainte de pivot
                tranzactie_info[:atins], tranzactie_info[:closing_dt] = rez
                # Închidem tranzacția
                tranzactie_deschisa = false
                process_type = nil
                conditii_initiale = {}
                data_deschidere = nil
                inchisa_inainte_pivot = true
                break
              end
            else
              # După pivot
              rez = check_inchidere.call(row, process_type, conditii_initiale)
              if rez
                # Închisă după pivot
                tranzactie_info[:atins], tranzactie_info[:closing_dt] = rez
                # Închidem tranzacția
                tranzactie_deschisa = false
                process_type = nil
                conditii_initiale = {}
                data_deschidere = nil
                inchisa_dupa_pivot = true
                break
              end
            end
          end
  
          if inchisa_inainte_pivot
            # Tranzacția veche s-a închis înainte de pivot
            # Putem acum iniția una nouă după pivot în aceeași zi
            # Dar întâi, completăm ziua de start a tranzacției vechi cu datele de închidere
            if tranzactie_info[:start_date] && tranzactie_info[:closing_dt]
              # Actualizăm ziua de start a tranzacției vechi
              sd = tranzactie_info[:start_date]
              daily_data[sd][:atins] = tranzactie_info[:atins]
              daily_data[sd][:closing_time] = tranzactie_info[:closing_dt].strftime('%Y-%m-%d %H:%M:%S')
            end
  
            # Resetăm info tranzacție veche
            tranzactie_info = { start_date: nil, atins: nil, closing_dt: nil }
  
            # Pornim tranzacția nouă după pivot
            in_process = false
            process_type_local = nil
            minute_curente.each do |row|
              next if row.timestamp.strftime('%H:%M') < @ora_pivot
              unless in_process
                if row.high >= zi[:entry_buy]
                  in_process = true
                  process_type_local = 'buy'
                  tranzactie_deschisa = true
                  process_type = 'buy'
                  conditii_initiale = zi
                  data_deschidere = current_date
                  tranzactie_info[:start_date] = current_date
                elsif row.low <= zi[:entry_sell]
                  in_process = true
                  process_type_local = 'sell'
                  tranzactie_deschisa = true
                  process_type = 'sell'
                  conditii_initiale = zi
                  data_deschidere = current_date
                  tranzactie_info[:start_date] = current_date
                else
                  next
                end
              end
  
              if process_type_local
                rez = check_inchidere.call(row, process_type_local, conditii_initiale)
                if rez
                  # Închisă în aceeași zi
                  tranzactie_info[:atins], tranzactie_info[:closing_dt] = rez
                  # Închidem tranzacția
                  tranzactie_deschisa = false
                  process_type = nil
                  conditii_initiale = {}
                  data_deschidere = nil
  
                  # Actualizăm ziua de start (care e current_date)
                  sd = tranzactie_info[:start_date]
                  daily_data[sd][:atins] = tranzactie_info[:atins]
                  daily_data[sd][:closing_time] = tranzactie_info[:closing_dt].strftime('%Y-%m-%d %H:%M:%S')
  
                  # Reset info tranzacție
                  tranzactie_info = { start_date: nil, atins: nil, closing_dt: nil }
                  break
                end
              end
            end
  
          elsif inchisa_dupa_pivot
            # S-a închis după pivot
            # Nu inițiem nimic nou azi.
            # Actualizăm ziua de start a tranzacției
            if tranzactie_info[:start_date] && tranzactie_info[:closing_dt]
              sd = tranzactie_info[:start_date]
              daily_data[sd][:atins] = tranzactie_info[:atins]
              daily_data[sd][:closing_time] = tranzactie_info[:closing_dt].strftime('%Y-%m-%d %H:%M:%S')
            end
            tranzactie_info = { start_date: nil, atins: nil, closing_dt: nil }
  
          else
            # Nu s-a închis deloc în ziua curentă
            # Nimic nou, tranzacția continuă ziua următoare
          end
  
        else
          # Nu avem tranzacție veche deschisă la începutul zilei
          in_process = false
          process_type_local = nil
          minute_curente.each do |row|
            next if row.timestamp.strftime('%H:%M') < @ora_pivot
            unless in_process
              if row.high >= zi[:entry_buy]
                in_process = true
                process_type_local = 'buy'
                tranzactie_deschisa = true
                process_type = 'buy'
                conditii_initiale = zi
                data_deschidere = current_date
                tranzactie_info[:start_date] = current_date
              elsif row.low <= zi[:entry_sell]
                in_process = true
                process_type_local = 'sell'
                tranzactie_deschisa = true
                process_type = 'sell'
                conditii_initiale = zi
                data_deschidere = current_date
                tranzactie_info[:start_date] = current_date
              else
                next
              end
            end
  
            if process_type_local
              rez = check_inchidere.call(row, process_type_local, conditii_initiale)
              if rez
                # Închisă în aceeași zi
                tranzactie_info[:atins], tranzactie_info[:closing_dt] = rez
                # Închidem tranzacția
                tranzactie_deschisa = false
                process_type = nil
                conditii_initiale = {}
                data_deschidere = nil
  
                # Actualizăm ziua de start
                sd = tranzactie_info[:start_date]
                daily_data[sd][:atins] = tranzactie_info[:atins]
                daily_data[sd][:closing_time] = tranzactie_info[:closing_dt].strftime('%Y-%m-%d %H:%M:%S')
  
                tranzactie_info = { start_date: nil, atins: nil, closing_dt: nil }
                break
              end
            end
          end
          # Dacă nu s-a închis, rămâne deschisă
        end
      end
  
      # După ce am terminat toate zilele:
      # Dacă mai există tranzacție deschisă și nu s-a închis niciodată, rămâne N/A la ziua de start.
      # Dacă s-a închis, am actualizat deja ziua de start.
  
      # Convertim daily_data în array pentru afișare
      @rezultate = daily_data.values.sort_by {|r| r[:date] }
  
      render :analiza_us30_tabel
    end
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
