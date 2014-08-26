emailjs = require 'emailjs'
getJSON = require 'get-json-plz'
_ = require 'underscore'

server = emailjs.server.connect {
	user: 'cyopticsmexico@gmail.com'
	password:'kerberos86'
	host:'smtp.gmail.com'
	# ssl:false
	tls: true
	port:587
}

getJSON 'http://jupiter.avagotech.net/apps/qa/maint-dev/toolbox/toolbox.php?action=getAllPending',(err, res)->
	# Ya que tengo los datos, tengo que filtrar por ASIGNADOS Y NO ASIGNADOS
	# Despues a los que no esten asignados, les tengo que enviar un correo a los Supervisores, anunciando los mantenimientos que estan pendientes de asignar
	# Y enviar las notificaciones a los usuarios que tienen mantenimientos pendientes
	_.map _.groupBy(res, 'MAINT_OPER'), (el, name)->
		if name isnt 'null'
			email = el[0].EMAIL
			supervisor = el[0].SUPERVISOR
			Message =_.template("<%= name %>\n\n 
				Tienes [<%= maint.length%>] mantenimientos asignados, 
				mismos que tienes que completar durante la semana:\n\n
				<% _.each(maint, function(single) {%><%= single.MAINT_ID %>: <%= single.E_DESC %>\n <% });%>\n\n\n
				Si tienes problemas para completar los mantenimientos dirigete con #{supervisor}\n
				Si tu correo '<%=maint[0].EMAIL%>' no corresponde con la cuenta '<%= name %>' envia un correo a
				aldo.mendez@avagotech.com para hacer la correccion")({maint:el, name:name})
			list = ""
			console.log email
			server.send {
				from:'MaintBot <cyopticsmexico@gmail.com>'
				to:"aldo.mendez@avagotech.com,#{email}"
				subject:'Mantenimientos'
				text:Message
			}, (err, message)->
				console.log "Error: #{err}" or "Message: #{message}"
		if name is 'null'
			console.log  _.groupBy el,'SUPERVISOR'













# para enviar el correo solo tengo que ejecutar
# node ./js/email.js