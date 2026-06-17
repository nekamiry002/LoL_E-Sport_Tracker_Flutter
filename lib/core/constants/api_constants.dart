const String kLolesportsBaseUrl = 'https://lolesports.com/api/gql';

const String kEsportsApiBaseUrl = 'https://esports-api.lolesports.com/persisted/gw';
const String kEsportsApiKey = '0TvQnueqKa5mxJntVWt0w4LpLfEkrV1Ta8rQBb9Z';

const String kGqlHash =
    '7246add6f577cf30b304e651bf9e25fc6a41fe49aeafb0754c16b5778060fc0a';

const Map<String, String> kLolesportsHeaders = {
  'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0',
  'Accept': '*/*',
  'Accept-Language': 'fr,fr-FR;q=0.7,en;q=0.3',
  'Accept-Encoding': 'gzip, deflate',
  'Referer': 'https://lolesports.com',
  'content-type': 'application/json',
  'apollographql-client-name': 'Esports Web',
  'apollographql-client-version': '04afdab',
  'Connection': 'keep-alive',
  'Sec-Fetch-Dest': 'empty',
  'Sec-Fetch-Mode': 'cors',
  'Sec-Fetch-Site': 'same-origin',
  'DNT': '1',
  'Sec-GPC': '1',
};

const Map<String, String> kLeagueIds = {
  'emea_masters': '100695891328981122',
  'first_stand': '113464388705111224',
  'msi': '98767975604431411',
  'worlds': '98767991325878492',
  'lec': '98767991302996019',
  'lfl': '105266103462388553',
};
