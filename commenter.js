let mount_point = $('script[data-commenter-url]')
let [url, pass] = mount_point.data('commenterUrl').split('//')[1].split('#')
let api_endpoint = 'https://anon:' + pass + '@' + url

$('script[data-commenter-url]').last().parent().append('<section class="comments"><article><p>Ejemplo</p></article>' +
  '<form method="post" action="' + api_endpoint + '"><label>Comentario: <textarea name="body"></textarea>' +
  '<input type="submit"></form></section>')

console.log(url, pass)
