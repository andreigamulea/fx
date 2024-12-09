class BtcsController < ApplicationController
  before_action :set_btc, only: %i[ show edit update destroy ]
 
  def preluare_btc
    Btc.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('btcs')
  
    # Calea către fișierul Excel
    xlsx = Roo::Spreadsheet.open(File.join(Rails.root, 'app', 'fisierele', 'BTCUSD.xlsx'))
  
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
      if Btc.exists?(date: formatted_date, timestamp: parsed_time)
        puts "Înregistrarea există deja: #{formatted_date} #{parsed_time}."
        next
      end
  
      # Creează o nouă înregistrare în tabel
      btc = Btc.new(
        date: formatted_date,
        timestamp: parsed_time,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume
      )
  
      # Salvează înregistrarea
      if btc.save
        #puts "Înregistrarea a fost salvată cu succes: #{btc.inspect}"
      else
        #puts "Eroare la salvarea înregistrării: #{btc.errors.full_messages.join(', ')}"
      end
    end
  
    redirect_to home_preluare_path
  end
  
  def preluare_btc1
    Btc.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('btcs')
  
    # Calea către fișierul Excel
    xlsx = Roo::Spreadsheet.open(File.join(Rails.root, 'app', 'fisierele', 'BTCUSD.xlsx'))
  
    puts "Fișier Excel deschis cu succes. Încep procesarea rândurilor..."
  
    records = []
  
    # Iterează prin fiecare rând din fișier, pornind de la al doilea rând (pentru a sări header-ul)
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
  
      begin
        # Convertim data și ora în formatul corect
        formatted_date = Date.strptime(date, '%Y%m%d')
        parsed_time = if raw_time.is_a?(Numeric)
                        # Timp numeric
                        Time.at(raw_time.to_i).strftime("%H:%M:%S")
                      else
                        # Format text
                        raw_time.strip
                      end
      rescue ArgumentError => e
        puts "Eroare la parsarea timestamp-ului: #{e.message}. Rând sărit."
        next
      end
  
      # Adaugă rândul în lista de înregistrări
      records << Btc.new(
        date: formatted_date,
        timestamp: parsed_time,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume
      )
    end
  
    # Importă toate înregistrările odată
    if records.any?
      Btc.import(records)
      puts "Import complet: #{records.size} rânduri au fost salvate."
    else
      puts "Nicio înregistrare validă pentru import."
    end
  
    redirect_to home_preluare_path
  end
  
  
  



  # GET /btcs or /btcs.json
  def index
    @btcs = Btc.all
  end

  # GET /btcs/1 or /btcs/1.json
  def show
  end

  # GET /btcs/new
  def new
    @btc = Btc.new
  end

  # GET /btcs/1/edit
  def edit
  end

  # POST /btcs or /btcs.json
  def create
    @btc = Btc.new(btc_params)

    respond_to do |format|
      if @btc.save
        format.html { redirect_to @btc, notice: "Btc was successfully created." }
        format.json { render :show, status: :created, location: @btc }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @btc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /btcs/1 or /btcs/1.json
  def update
    respond_to do |format|
      if @btc.update(btc_params)
        format.html { redirect_to @btc, notice: "Btc was successfully updated." }
        format.json { render :show, status: :ok, location: @btc }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @btc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /btcs/1 or /btcs/1.json
  def destroy
    @btc.destroy!

    respond_to do |format|
      format.html { redirect_to btcs_path, status: :see_other, notice: "Btc was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_btc
      @btc = Btc.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def btc_params
      params.require(:btc).permit(:date, :timestamp, :open, :high, :low, :close, :volume)
    end
end
