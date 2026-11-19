/*
 * StroomQL (Stroom Query Language) support for PrismJS.
 *
 * This file is hand written and is NOT part of the generated prism.js download,
 * so it is not lost when prism.js is replaced with a new download.
 * It must be loaded after prism.js.
 */
(function (Prism) {

  // Every word that StroomQL treats as a keyword, including the words of the
  // join kinds, time windows, conditions and sort directions.
  var keywords = [
    'from', 'sql', 'as',
    'join', 'inner', 'left', 'right', 'full', 'outer', 'semi', 'anti',
    'on', 'within', 'after', 'before',
    'where', 'filter', 'having',
    'and', 'or', 'not',
    'between', 'in', 'dictionary', 'is', 'null', 'exists',
    'eval', 'window', 'by', 'advance',
    'group', 'sort', 'asc', 'desc',
    'limit', 'select', 'show'
  ];

  Prism.languages.stroomql = {
    'comment': [
      {
        pattern: /(^|[^\\])\/\*[\s\S]*?(?:\*\/|$)/,
        lookbehind: true,
        greedy: true
      },
      {
        // The lookbehind stops the '//' of a URL being treated as a comment.
        pattern: /(^|[^\\:])\/\/.*/,
        lookbehind: true,
        greedy: true
      }
    ],
    'string': [
      {
        // A triple quoted native query, which may span lines.
        pattern: /"""[\s\S]*?"""/,
        greedy: true
      },
      {
        pattern: /"(?:\\.|[^"\\\r\n])*"|'(?:\\.|[^'\\\r\n])*'/,
        greedy: true
      }
    ],
    // A field whose name has spaces, or a dashboard parameter, e.g. ${Create Time}.
    'variable': /\$\{[^}]*\}/,
    'keyword': new RegExp('\\b(?:' + keywords.join('|') + ')\\b', 'i'),
    'boolean': /\b(?:true|false)\b/i,
    // Any other name that is followed by an opening bracket, e.g. count().
    'function': /\b[a-z_]\w*(?=\s*\()/i,
    'number': [
      // A date time, e.g. 2024-01-01T00:00:00.000Z.
      /\b\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?Z?\b/,
      // A duration, e.g. 10m or 500ms.
      /\b\d+(?:ns|ms|s|m|h|d|w|M|y)\b/,
      /\b\d+(?:\.\d+)?\b/
    ],
    'operator': /!=|<=|>=|[=<>+\-*\/%^]/,
    'punctuation': /[(),.]/
  };

}(Prism));
