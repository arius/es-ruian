# es_ruian

Ruby klient pro [RÚIAN API](https://ruian.eurosignal.cz/api) (Eurosignal). Gem poskytuje tenkou vrstvu nad REST endpointy pro práci s adresními místy, parcelemi, vyhledáváním, autocomplete a asynchronní aktualizací obcí.

**API base URL (produkce):** `https://ruian.eurosignal.cz/api`

## Instalace

Do `Gemfile`:

```ruby
gem 'es_ruian'
```

```bash
bundle install
```

Nebo přímo:

```bash
gem install es_ruian
```

## Rychlý start

```ruby
require 'es_ruian'

# Adresa podle RÚIAN kódu
EsRuian::AddressPlace.by_code(30762961)

# Fulltextové vyhledávání
EsRuian::Search.by_fulltext("Holice, Vysokomýtská 289")

# Autocomplete obcí
EsRuian::Autocomplete.municipalities_by_filter("Brn")

# Aktualizace obce podle kódu adresního místa
EsRuian::MunicipalityRefresh.refresh_by_address_code!(30762961)
```

## Konfigurace

Gem načte výchozí hodnoty při `require 'es_ruian'`. Lze je přepsat přes proměnné prostředí nebo blokem.

### Proměnné prostředí

| Proměnná | Výchozí | Popis |
|----------|---------|-------|
| `RUIAN_API_BASE_URL` | `https://ruian.eurosignal.cz/api` | Base URL API |
| `RUIAN_REFRESH_POLL_INTERVAL_SECONDS` | `10` | Interval pollingu stavu city update (s) |
| `RUIAN_REFRESH_TIMEOUT_SECONDS` | `1800` | Timeout pollingu city update (s, 30 min) |

### Programová konfigurace

```ruby
EsRuian::Configuration.configure do |config|
  config.api_url = "http://localhost:3000/api"
  config.refresh_poll_interval_seconds = 10
  config.refresh_timeout_seconds = 1800
end
```

### YAML konfigurace (Rails / Rack)

```ruby
EsRuian::Configuration.configure("config/es_ruian.yml")
```

```yaml
# config/es_ruian.yml
development:
  api_url: http://localhost:3000/api
production:
  api_url: https://ruian.eurosignal.cz/api
```

## Formát odpovědí

Většina endpointů prochází třídou `EsRuian::Connector`, která:

- volá JSON:API endpointy s hlavičkou `Accept: application/vnd.api+json`
- očekává HTTP **200 OK**
- z odpovědi extrahuje pole `data` a vrací **pole hashů** s atributy (`attributes` z JSON:API)

Výjimkou je `EsRuian::MunicipalityRefresh`, který pracuje s jiným formátem odpovědi (viz níže).

Při chybě HTTP statusu `Connector` vyhodí výjimku s textem statusu (např. `"404 Not Found"`).

---

## EsRuian::AddressPlace

Práce s adresními místy (RÚIAN `AdresniMisto`).

| Metoda | HTTP | Popis |
|--------|------|-------|
| `by_code(code)` | GET `/addresses/by_code/:code` | Adresa podle kódu adresního místa |
| `by_codes(*codes)` | POST `/addresses/by-codes` | Více adres najednou (`{ codes: [...] }`) |
| `by_municipality(code)` | GET `/addresses/by_municipality/:code` | Adresy v obci |
| `by_street(code)` | GET `/addresses/by_street/:code` | Adresy v ulici |
| `by_district(code)` | GET `/addresses/by_district/:code` | Adresy v okresu |
| `by_region(code)` | GET `/addresses/by_province/:code` | Adresy v kraji |
| `by_partOfMunicipality(code)` | GET `/addresses/by_municipality_part/:code` | Adresy v části obce |
| `by_street_code_and_house_numbers(street_code, house_numbers)` | GET | Adresy podle ulice a čísel |
| `by_municipality_code_and_house_numbers(municipality_code, house_numbers)` | GET | Adresy podle obce a čísel |
| `by_circle(lat, lon, radius, options = {})` | GET `/addresses/by_circle/...` | Adresy v okruhu |
| `by_polygon(data, options = {})` | POST `/addresses/by_polygon` | Adresy v polygonu |

```ruby
EsRuian::AddressPlace.by_code(34711)
EsRuian::AddressPlace.by_codes(34711, 34746, 34789)
EsRuian::AddressPlace.by_municipality(530395)
EsRuian::AddressPlace.by_circle(48.99559, 16.72451, 0.1)
```

---

## EsRuian::Search

Vyhledávání adres a parcel.

| Metoda | HTTP | Popis |
|--------|------|-------|
| `by_filter(filter_param)` | POST `/search/by-filter` | Filtr: `municipality`, `street`, `house_number`, … |
| `multiple_by_filter(filter_param)` | POST `/search/multiple-by-filter` | Více filtrů najednou |
| `by_fulltext(text, options = {})` | GET `/search/by_fulltext/:text` | Fulltextové hledání |
| `multiple_by_fulltext(*params)` | POST `/search/multiple-by-fulltext` | Více fulltext dotazů |
| `by_polygon(data, options = {})` | POST `/search/by_polygon` | Hledání v polygonu |
| `by_circle(lat, lon, radius, options = {})` | GET `/search/by_circle/...` | Hledání v okruhu |

Dostupné filtry pro `by_filter`: `municipality`, `municipality_code`, `street`, `street_code`, `part_of_municipality`, `part_of_municipality_code`, `region`, `region_code`, `house_number`, `orientation_number`.

Parametr `kind` u geometrického hledání: `address` (jen adresy), `parcel` (jen parcely), výchozí obojí.

```ruby
EsRuian::Search.by_filter(municipality: "Brno", street: "Rooseveltova")
EsRuian::Search.by_fulltext("Holice, Vysokomýtská 289")
EsRuian::Search.by_circle(48.99559, 16.72451, 0.1, kind: "parcel")
```

---

## EsRuian::Autocomplete

Autocomplete pro formuláře (obce, ulice, čísla popisná).

| Metoda | Popis |
|--------|-------|
| `municipalities_by_filter(text)` | Obce podle prefixu |
| `municipalities_with_parts_by_filter(text)` | Obce včetně částí obce |
| `districts_by_filter(text)` | Okresy |
| `streets_by_filter(city_code, text)` | Ulice v obci |
| `streets_by_part_of_city_filter(part_code, text)` | Ulice v části obce |
| `house_numbers_by_street_code(street_code, filter)` | Čísla popisná v ulici |
| `house_numbers_without_street_by_city_code(city_code, filter)` | Čísla v obci bez ulice |
| `house_numbers_without_street_by_part_of_city_code(part_code)` | Čísla v části obce bez ulice |

```ruby
EsRuian::Autocomplete.municipalities_by_filter("Brn")
EsRuian::Autocomplete.streets_by_filter(535419, "Adiny")
EsRuian::Autocomplete.house_numbers_by_street_code(370410, "12")
```

---

## EsRuian::Parcel

Práce s parcelami.

| Metoda | HTTP | Popis |
|--------|------|-------|
| `by_code(code, options = {})` | GET `/parcels/by_code/:code` | Parcela podle kódu |
| `by_circle(lat, lon, radius, options = {})` | GET | Parcely v okruhu (`kind: parcel`) |
| `by_polygon(*data)` | POST `/parcels/by_polygon` | Parcely v polygonu |
| `by_cadastral_area_and_parcel_number(area_code, number, options = {})` | GET | Parcela podle katastru a čísla |
| `by_fulltext(area_code, number, options = {})` | GET | Fulltext hledání parcely |

```ruby
EsRuian::Parcel.by_code(107611508)
EsRuian::Parcel.by_cadastral_area_and_parcel_number(600083, 1)
EsRuian::Parcel.by_circle(48.99559, 16.72451, 0.1)
```

---

## EsRuian::AdministrativeDivision

Správní členění (kraj, okres, obec …).

| Metoda | Popis |
|--------|-------|
| `by_gps(lat, lon, options = {})` | Správní celek podle GPS |
| `by_name(name, options = {})` | Podle názvu |
| `by_code(code, options = {})` | Podle kódu |

```ruby
EsRuian::AdministrativeDivision.by_gps(49.9278992, 14.3389639)
EsRuian::AdministrativeDivision.by_name("Beroun")
```

---

## EsRuian::CadastralZoning

Katastrální území.

| Metoda | Popis |
|--------|-------|
| `by_gps(lat, lon, options = {})` | Katastr podle GPS |
| `by_name(name, options = {})` | Podle názvu |
| `by_code(code, options = {})` | Podle kódu |

```ruby
EsRuian::CadastralZoning.by_gps(49.9278992, 14.3389639)
EsRuian::CadastralZoning.by_code(600083)
```

---

## EsRuian::MunicipalityRefresh

Asynchronní aktualizace celé obce podle kódu adresního místa. Odpovídá operaci z admin UI [Aktualizace podle obce](https://ruian.eurosignal.cz/city_updates/new).

API nemá autentizaci. POST nevyžaduje JSON body.

### Flow

1. `POST /city_updates/by_address_code/{code}` → `city_update_id`, `status: running`
2. Poll `GET /city_updates/{id}` každých N sekund, dokud `finished: true`
3. `status: completed` → úspěch, `status: failed` → chyba
4. Volitelně `GET /addresses/by_code/{code}` pro načtení aktualizované adresy

### Metody

| Metoda | Návratová hodnota | Popis |
|--------|-------------------|-------|
| `start_municipality_refresh(code)` | `Integer` (`city_update_id`) | Spustí refresh |
| `fetch_city_update_status(id)` | `Hash` | Aktuální stav updatu |
| `wait_for_city_update!(id, timeout:, interval:)` | `Hash` | Polluje do dokončení |
| `refresh_by_address_code!(code, poll:, fetch_address:)` | `Hash` nebo `{ city_update:, address: }` | Celý flow |
| `fetch_address(code)` | pole hashů | Načte adresu přes `AddressPlace` |

### Příklady

```ruby
# Celý flow — spustí, počká na dokončení, vrátí finální stav
result = EsRuian::MunicipalityRefresh.refresh_by_address_code!(30762961)
# => { "city_update_id" => 456, "status" => "completed", "finished" => true, ... }

# Po dokončení i s načtením adresy
result = EsRuian::MunicipalityRefresh.refresh_by_address_code!(
  30762961,
  fetch_address: true
)
# => { city_update: { ... }, address: [ { ... } ] }

# Jen spuštění bez čekání
city_update_id = EsRuian::MunicipalityRefresh.start_municipality_refresh(30762961)

# Ruční polling
status = EsRuian::MunicipalityRefresh.wait_for_city_update!(
  city_update_id,
  timeout: 1800,
  interval: 10
)

# Vlastní instance s jinou konfigurací
client = EsRuian::MunicipalityRefresh.new(
  base_url: "http://localhost:3000/api",
  poll_interval: 5,
  timeout: 600
)
client.refresh_by_address_code!(30762961)
```

### Struktura odpovědi city update

```json
{
  "city_update_id": 456,
  "status": "completed",
  "finished": true,
  "municipality_id": 598850,
  "municipality_name": "Beroun",
  "address_place_code": 30762961,
  "records_imported": 150,
  "records_updated": 42,
  "records_deleted": 3,
  "errors_count": 0,
  "error_messages": []
}
```

### Chybové stavy

| HTTP | Kdy | Výjimka |
|------|-----|---------|
| — | Nečíselný kód (validace klienta) | `Errors::InvalidAddressPlaceCodeError` |
| 400 | Neplatný kód | `Errors::InvalidAddressPlaceCodeError` |
| 404 | Adresa neexistuje (POST) | `Errors::AddressNotFoundError` |
| 404 | City update neexistuje (GET) | `Errors::CityUpdateNotFoundError` |
| 422 | Nelze určit obec | `Errors::MunicipalityNotDeterminableError` |
| 5xx | Chyba serveru | `Errors::ServerError` (retry s exponential backoff) |
| — | Timeout pollingu | `Errors::CityUpdateTimeoutError` |
| — | `status: failed` | `Errors::CityUpdateFailedError` |

```ruby
begin
  EsRuian::MunicipalityRefresh.refresh_by_address_code!(30762961)
rescue EsRuian::Errors::AddressNotFoundError => e
  puts "Adresa nenalezena: #{e.message}"
rescue EsRuian::Errors::CityUpdateFailedError => e
  puts "Import selhal: #{e.error_messages.join(', ')}"
end
```

---

## EsRuian::Errors

Typované výjimky pro `MunicipalityRefresh`:

| Třída | Popis |
|-------|-------|
| `Errors::Error` | Základní výjimka modulu |
| `Errors::InvalidAddressPlaceCodeError` | Neplatný formát kódu adresy |
| `Errors::AddressNotFoundError` | Adresní místo v DB neexistuje |
| `Errors::MunicipalityNotDeterminableError` | Adresa existuje, obec nejde určit |
| `Errors::CityUpdateNotFoundError` | City update s daným ID neexistuje |
| `Errors::CityUpdateFailedError` | Import skončil se `status: failed` |
| `Errors::CityUpdateTimeoutError` | Polling překročil timeout |
| `Errors::ServerError` | HTTP 5xx |
| `Errors::ApiError` | Ostatní neočekávané chyby |

`CityUpdateFailedError` navíc exposeuje `#error_messages` a `#city_update`.

---

## EsRuian::RuianPlace

Pomocná třída (`OpenStruct`) pro práci s objekty z RÚIAN. Poskytuje:

- `#latitude`, `#longitude` — z GPS souřadnic
- `#ruian_code` — alias pro `#id`

---

## Závislosti

| Gem | Účel |
|-----|------|
| `curb` | HTTP klient (libcurl) |

Gem předpokládá běh v Rails/Rack aplikaci s **ActiveSupport** (metody jako `blank?`, `to_query` v `Connector`).

---

## Vývoj

```bash
git clone https://github.com/iquest/es_ruian.git
cd es_ruian
bin/setup
```

Interaktivní konzole:

```bash
bin/console
# nebo
bundle exec rake console
```

Instalace lokálně:

```bash
bundle exec rake install
```

Release:

```bash
# upravte lib/es_ruian/version.rb
bundle exec rake release
```

---

## Licence

MIT — viz [LICENSE.txt](LICENSE.txt).
