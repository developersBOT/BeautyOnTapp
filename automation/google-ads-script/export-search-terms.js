/**
 * BeautyOnTApp Marketing Automation Fleet
 * Google Ads Script — daily search-term export
 * ---------------------------------------------------------------------------
 * WHY THIS EXISTS
 * There is no Google Ads API or MCP connector available to the fleet, so agents
 * 01 (PPC Audit) and 05 (Keywords + Negatives) cannot read the account's own
 * search-term data directly. This script closes that loop: it runs inside
 * Google Ads on a schedule, writes the search-term report to a Google Sheet,
 * and the agents fetch that Sheet automatically each morning.
 *
 * ONE-TIME INSTALL (about 5 minutes, once per account — then fully automatic)
 *  1. Create a blank Google Sheet. Copy its URL.
 *  2. Paste that URL into SPREADSHEET_URL below.
 *  3. Google Ads → Tools → Bulk actions → Scripts → "+" → paste this file.
 *  4. Authorize, then Preview once to confirm it writes rows.
 *  5. Schedule it: Frequency → Daily → 07:00 (before the 08:00 SAST fleet run).
 *  6. In the Sheet: File → Share → Publish to web → the `search_terms` sheet →
 *     Comma-separated values (.csv) → Publish. Copy the published CSV URL.
 *  7. Put that CSV URL into automation/config.yaml under the brand's
 *     `google_ads.search_terms_csv_url`. Commit and push.
 *
 * Repeat for each account: BoT 820-452-9325 and Pastry 851-084-2703.
 * After this, agents 01 and 05 get real account data with zero manual work.
 * ---------------------------------------------------------------------------
 */

// ---- CONFIG ---------------------------------------------------------------
var SPREADSHEET_URL = 'PASTE_YOUR_GOOGLE_SHEET_URL_HERE';
var SHEET_NAME = 'search_terms';
var LOOKBACK_DAYS = 7;          // fleet uses 7-30 days; 7 keeps it current
var MIN_IMPRESSIONS = 1;        // skip pure noise
// ---------------------------------------------------------------------------

function main() {
  if (SPREADSHEET_URL.indexOf('PASTE_YOUR') === 0) {
    throw new Error('Set SPREADSHEET_URL to your Google Sheet URL before running.');
  }

  var spreadsheet = SpreadsheetApp.openByUrl(SPREADSHEET_URL);
  var sheet = spreadsheet.getSheetByName(SHEET_NAME);
  if (!sheet) {
    sheet = spreadsheet.insertSheet(SHEET_NAME);
  }
  sheet.clear();

  // Column names match what the fleet's sqr-negatives-pipeline expects.
  var rows = [[
    'Search term',
    'Match type',
    'Added/Excluded',
    'Campaign',
    'Ad group',
    'Clicks',
    'Impressions',
    'Cost',
    'Conversions',
    'Cost / conv.',
    'Conv. rate'
  ]];

  var range = getDateRange(LOOKBACK_DAYS);
  var query =
    'SELECT ' +
    '  search_term_view.search_term, ' +
    '  search_term_view.status, ' +
    '  segments.search_term_match_type, ' +
    '  campaign.name, ' +
    '  ad_group.name, ' +
    '  metrics.clicks, ' +
    '  metrics.impressions, ' +
    '  metrics.cost_micros, ' +
    '  metrics.conversions, ' +
    '  metrics.cost_per_conversion, ' +
    '  metrics.conversions_from_interactions_rate ' +
    'FROM search_term_view ' +
    "WHERE segments.date BETWEEN '" + range.start + "' AND '" + range.end + "' " +
    '  AND metrics.impressions >= ' + MIN_IMPRESSIONS + ' ' +
    'ORDER BY metrics.cost_micros DESC';

  var iterator = AdsApp.search(query);

  while (iterator.hasNext()) {
    var row = iterator.next();
    var metrics = row.metrics || {};

    rows.push([
      getPath(row, ['searchTermView', 'searchTerm'], ''),
      getPath(row, ['segments', 'searchTermMatchType'], ''),
      getPath(row, ['searchTermView', 'status'], ''),
      getPath(row, ['campaign', 'name'], ''),
      getPath(row, ['adGroup', 'name'], ''),
      toNumber(metrics.clicks),
      toNumber(metrics.impressions),
      toNumber(metrics.costMicros) / 1000000,
      toNumber(metrics.conversions),
      toNumber(metrics.costPerConversion) / 1000000,
      toNumber(metrics.conversionsFromInteractionsRate)
    ]);
  }

  if (rows.length === 1) {
    Logger.log('No search terms found for ' + range.start + '..' + range.end);
  }

  sheet.getRange(1, 1, rows.length, rows[0].length).setValues(rows);

  // Stamp the run so the fleet can tell whether the export is stale.
  var meta = spreadsheet.getSheetByName('_meta') || spreadsheet.insertSheet('_meta');
  meta.clear();
  meta.getRange(1, 1, 4, 2).setValues([
    ['account_id', AdsApp.currentAccount().getCustomerId()],
    ['account_name', AdsApp.currentAccount().getName()],
    ['date_range', range.start + ' to ' + range.end],
    ['generated_at', Utilities.formatDate(new Date(), AdsApp.currentAccount().getTimeZone(), 'yyyy-MM-dd HH:mm:ss z')]
  ]);

  Logger.log('Wrote ' + (rows.length - 1) + ' search terms for ' +
             AdsApp.currentAccount().getCustomerId() + ' (' + range.start + '..' + range.end + ')');
}

/** Inclusive date range ending yesterday (today's data is still settling). */
function getDateRange(lookbackDays) {
  var timeZone = AdsApp.currentAccount().getTimeZone();
  var end = new Date();
  end.setDate(end.getDate() - 1);
  var start = new Date();
  start.setDate(start.getDate() - lookbackDays);
  return {
    start: Utilities.formatDate(start, timeZone, 'yyyy-MM-dd'),
    end: Utilities.formatDate(end, timeZone, 'yyyy-MM-dd')
  };
}

/** Safe nested property read — the API omits empty fields entirely. */
function getPath(object, path, fallback) {
  var cursor = object;
  for (var i = 0; i < path.length; i++) {
    if (cursor === null || cursor === undefined) return fallback;
    cursor = cursor[path[i]];
  }
  return (cursor === null || cursor === undefined) ? fallback : cursor;
}

function toNumber(value) {
  var n = Number(value);
  return isNaN(n) ? 0 : n;
}
