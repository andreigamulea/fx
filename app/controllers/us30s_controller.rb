class Us30sController < ApplicationController
  before_action :set_us30, only: %i[ show edit update destroy ]
  #
  def preluare_us30
    Us30.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('us30s')
  
    # Calea către fișierul Excel
    xlsx = Roo::Spreadsheet.open(File.join(Rails.root, 'app', 'fisierele', 'US30.xlsx'))
  
    puts "Fișier Excel deschis cu succes. Încep procesarea rândurilor..."
  
    # Iterează prin fiecare rând din fișier, pornind de la al doilea rând (pentru a sări header-ul)
    xlsx.each_row_streaming(offset: 1, pad_cells: true) do |row|
      # Debugging: Afișează valorile brute din rând
      puts "Valorile brute din rând: #{row.map(&:value)}"
  
      # Extrage valorile din rând
      date = row[0]&.value.to_s.strip # Data în format YYYYMMDD
      raw_time = row[1]&.value       # Ora brută (numerică sau text)
      open = row[2]&.value.to_d      # Prețul de deschidere
      high = row[3]&.value.to_d      # Prețul maxim
      low = row[4]&.value.to_d       # Prețul minim
      close = row[5]&.value.to_d     # Prețul de închidere
      volume = row[6]&.value.to_d    # Volumul
  
      # Sari peste rând dacă vreun câmp esențial lipsește
      if date.blank? || raw_time.blank? || open.blank? || high.blank? || low.blank? || close.blank? || volume.blank?
        puts "Rând sărit: Lipsesc date esențiale."
        next
      end
  
      begin
        # Convertim data în formatul corect
        formatted_date = Date.strptime(date, '%Y%m%d')
  
        # Tratarea timestamp-ului
        parsed_time = if raw_time.is_a?(Numeric)
                        # Excel stochează timpul ca număr de secunde de la 00:00
                        Time.at(raw_time.to_i).strftime("%H:%M:%S")
                      elsif raw_time.is_a?(String) && raw_time.include?(":")
                        # Direct string în format HH:MM:SS
                        raw_time.strip
                      else
                        raise ArgumentError, "Format necunoscut pentru timestamp: #{raw_time.inspect}"
                      end
      rescue ArgumentError => e
        puts "Eroare la parsarea timestamp-ului: #{e.message}. Rând sărit."
        next
      end
  
      # Verifică dacă înregistrarea există deja în tabel
      if Us30.exists?(date: formatted_date, timestamp: parsed_time)
        puts "Înregistrarea există deja: #{formatted_date} #{parsed_time}."
        next
      end
  
      # Creează o nouă înregistrare în tabel
      us30 = Us30.new(
        date: formatted_date,
        timestamp: parsed_time,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume
      )
  
      # Salvează înregistrarea
      if us30.save
        puts "Înregistrarea a fost salvată cu succes: #{us30.inspect}"
      else
        puts "Eroare la salvarea înregistrării: #{us30.errors.full_messages.join(', ')}"
      end
    end
  
    redirect_to home_preluare_path
  end
  
  

  def preluare_us301
    Us30.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('us30s')
  
    # Calea către fișierul Excel
    xlsx = Roo::Spreadsheet.open(File.join(Rails.root, 'app', 'fisierele', 'US30.xlsx'))
  
    puts "Fișier Excel deschis cu succes. Încep procesarea rândurilor..."
  
    records = []
    batch_size = 10_000 # Lot de 10.000 de rânduri
  
    xlsx.each_row_streaming(offset: 1, pad_cells: true) do |row|
      # Extrage valorile din rând
      date = row[0]&.value.to_s.strip # Data în format YYYYMMDD
      raw_time = row[1]&.value       # Ora brută (numerică sau text)
      open = row[2]&.value.to_d      # Prețul de deschidere
      high = row[3]&.value.to_d      # Prețul maxim
      low = row[4]&.value.to_d       # Prețul minim
      close = row[5]&.value.to_d     # Prețul de închidere
      volume = row[6]&.value.to_d    # Volumul
  
      # Sari peste rând dacă vreun câmp esențial lipsește
      next if date.blank? || raw_time.blank? || open.blank? || high.blank? || low.blank? || close.blank? || volume.blank?
  
      formatted_date = Date.strptime(date, '%Y%m%d')
      parsed_time = raw_time.is_a?(Numeric) ? Time.at(raw_time.to_i).strftime("%H:%M:%S") : raw_time.strip
  
      records << Us30.new(
        date: formatted_date,
        timestamp: parsed_time,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume
      )
  
      # Când lotul ajunge la 10.000 de rânduri, importă și resetează lista
      if records.size >= batch_size
        Us30.import(records)
        records.clear
        puts "Lot de 10.000 de rânduri importat cu succes."
      end
    end
  
    # Importă orice rânduri rămase după ultima iterare
    Us30.import(records) if records.any?
  
    puts "Import complet."
    redirect_to home_preluare_path
  end
  


  def preluare_us30_cu_duplicat
    # Calea către fișierul Excel
    xlsx = Roo::Spreadsheet.open(File.join(Rails.root, 'app', 'fisierele', 'US30.xlsx'))
  
    puts "Fișier Excel deschis cu succes. Încep procesarea rândurilor..."
  
    # Iterează prin fiecare rând din fișier, pornind de la al doilea rând (pentru a sări header-ul)
    xlsx.each_row_streaming(offset: 1, pad_cells: true) do |row|
      # Debugging: Afișează valorile brute din rând
      puts "Valorile brute din rând: #{row.map(&:value)}"
  
      # Extrage valorile din rând
      date = row[0]&.value.to_s.strip # Data în format YYYYMMDD
      raw_time = row[1]&.value       # Ora brută (numerică sau text)
      open = row[2]&.value.to_d      # Prețul de deschidere
      high = row[3]&.value.to_d      # Prețul maxim
      low = row[4]&.value.to_d       # Prețul minim
      close = row[5]&.value.to_d     # Prețul de închidere
      volume = row[6]&.value.to_d    # Volumul
  
      # Debugging: Afișează valorile individuale extrase
      puts "Data extrasă: #{date.inspect}"
      puts "Timestamp brut extras: #{raw_time.inspect}"
      puts "Preț Open: #{open.inspect}, High: #{high.inspect}, Low: #{low.inspect}, Close: #{close.inspect}, Volume: #{volume.inspect}"
  
      # Sari peste rând dacă vreun câmp esențial lipsește
      if date.blank? || raw_time.blank? || open.blank? || high.blank? || low.blank? || close.blank? || volume.blank?
        puts "Rând sărit: Lipsesc date esențiale."
        next
      end
  
      begin
        # Convertim data în formatul corect
        formatted_date = Date.strptime(date, '%Y%m%d')
  
        # Tratarea timestamp-ului
        if raw_time.is_a?(Numeric)
          # Excel stochează timpul în secunde de la 00:00
          total_seconds = raw_time.to_i
          hours = total_seconds / 3600
          minutes = (total_seconds % 3600) / 60
          seconds = total_seconds % 60
          time_string = format("%02d:%02d:%02d", hours, minutes, seconds)
          parsed_time = Time.parse(time_string)
          puts "Timestamp convertit din numeric: #{parsed_time}"
        elsif raw_time.is_a?(String) && raw_time.include?(":")
          # Format text din Excel
          parsed_time = Time.strptime(raw_time.strip, "%H:%M:%S")
          puts "Timestamp convertit din string: #{parsed_time}"
        else
          # Format necunoscut
          raise ArgumentError, "Format necunoscut pentru timestamp: #{raw_time.inspect}"
        end
      rescue ArgumentError => e
        puts "Eroare la parsarea timestamp-ului: #{e.message}. Rând sărit."
        next
      end
  
      # Debugging: Afișează valorile gata de inserat
      puts "Valorile finale pentru inserare: Date=#{formatted_date}, Time=#{parsed_time}, Open=#{open}, High=#{high}, Low=#{low}, Close=#{close}, Volume=#{volume}"
  
      # Creează o nouă înregistrare în tabel, fără verificare pentru existență
      us30 = Us30.new(
        date: formatted_date,
        timestamp: parsed_time.strftime("%H:%M:%S"),
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume
      )
  
      # Salvează înregistrarea
      if us30.save
        puts "Înregistrarea a fost salvată cu succes: #{us30.inspect}"
      else
        puts "Eroare la salvarea înregistrării: #{us30.errors.full_messages.join(', ')}"
      end
    end
  
    redirect_to home_preluare_path, notice: 'Datele au fost procesate și duplicatele sunt permise!'
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
            #if row.high >= cond[:tp_sx7]
              if row.low <= cond[:tp_sx7]
              return ["Sell2", closing_dt]
            #elsif row.high <= cond[:sl_sx7]
            elsif row.high >= cond[:sl_sx7]
              return ["SL", closing_dt]
            end
          end
        elsif tip == 'sell'
          if row.low <= cond[:tp_sell_stop]
            return ["Sell1", closing_dt]
          elsif row.high >= cond[:sl_sell]
            #if row.low <= cond[:tp_bx7]
              if row.high >= cond[:tp_bx7]
              return ["Buy2", closing_dt]
            #elsif row.low >= cond[:sl_bx7]
            elsif row.low <= cond[:sl_bx7]
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
  
  
  
  

  # GET /us30s or /us30s.json
  def index
    @us30s = Us30.all
  end

  # GET /us30s/1 or /us30s/1.json
  def show
  end

  # GET /us30s/new
  def new
    @us30 = Us30.new
  end

  # GET /us30s/1/edit
  def edit
  end

  # POST /us30s or /us30s.json
  def create
    @us30 = Us30.new(us30_params)

    respond_to do |format|
      if @us30.save
        format.html { redirect_to @us30, notice: "Us30 was successfully created." }
        format.json { render :show, status: :created, location: @us30 }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @us30.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /us30s/1 or /us30s/1.json
  def update
    respond_to do |format|
      if @us30.update(us30_params)
        format.html { redirect_to @us30, notice: "Us30 was successfully updated." }
        format.json { render :show, status: :ok, location: @us30 }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @us30.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /us30s/1 or /us30s/1.json
  def destroy
    @us30.destroy!

    respond_to do |format|
      format.html { redirect_to us30s_path, status: :see_other, notice: "Us30 was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_us30
      @us30 = Us30.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def us30_params
      params.require(:us30).permit(:date, :timestamp, :open, :high, :low, :close, :volume)
    end
end
