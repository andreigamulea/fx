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
          begin
            parsed_time = Time.strptime(raw_time.strip, "%H:%M:%S")
            puts "Timestamp convertit din string: #{parsed_time}"
          rescue ArgumentError
            # Încearcă formatul AM/PM dacă cel de mai sus eșuează
            parsed_time = Time.strptime(raw_time.strip, "%I:%M:%S %p")
            puts "Timestamp convertit din AM/PM string: #{parsed_time}"
          end
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
  
      # Verifică dacă înregistrarea există deja în tabel
      if Us30.exists?(date: formatted_date, timestamp: parsed_time.strftime("%H:%M:%S"))
        puts "Înregistrarea există deja: #{formatted_date} #{parsed_time}."
        next
      end
  
      # Creează o nouă înregistrare în tabel
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
