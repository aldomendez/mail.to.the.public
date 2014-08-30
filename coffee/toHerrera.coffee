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

pendingAssign = []
pendingComplete = []
assignEmail = []
completeEmail = []
pendingComplete.push "\nMantenimientos sin completar\n=============================\n"

getJSON 'http://jupiter.avagotech.net/apps/qa/maint-dev/toolbox/toolbox.php?action=getAllPending',(err, res)->
	# Ya que tengo los datos, tengo que filtrar por ASIGNADOS Y NO ASIGNADOS
	# Despues a los que no esten asignados, les tengo que enviar un correo a los Supervisores, anunciando los mantenimientos que estan pendientes de asignar
	# Y enviar las notificaciones a los usuarios que tienen mantenimientos pendientes
	_.map _.groupBy(res, 'MAINT_OPER'), (el, name)->
		if name is 'null'
			# Esta parte se ejecuta cuando name es 'null', o sea que no se le a asignado a nadie
			pendingAssign.push "Mantenimientos sin asignar #{el.length}\n=============================\n"
			_.map _.groupBy( el,'SUPERVISOR'), (el, name)->
				# Lo agrupo por supervisor para que a cada supervisor le lleguen los mantenimientos que tienen abiertos
				# y no han asignado.
				assignEmail.push el[0].SUP_EMAIL
				template =_.template(" <%= maint[0].SUPERVISOR %> [<%= maint.length%>]:\n
					  <% _.each(maint, function(single) {%> <%= single.MAINT_ID %>: <%= single.E_DESC %>\n <% });%>")({maint:el, name:name})
				pendingAssign.push template
		if name isnt 'null' and el[0].EMAIL?
			# Esta parte se ejecuta cuando 'name' (el nombre de la persona que tiene asignado el mantenimiento),
			# no es 'null', o sea que alguien lo tiene asignado.
			# console.log ""
			completeEmail.push el[0].EMAIL
			supervisor = el[0].SUPERVISOR
			template =_.template("<%= name %> [<%= maint.length%>] \n
				<% _.each(maint, function(single) {%><%= single.MAINT_ID %>: <%= single.E_DESC %>\n <% });%>\n")({maint:el, name:name})
			pendingComplete.push template
	message = ""
	message += pendingAssign.join '\n'
	message += pendingComplete.join '\n'
	message += "Lista de correos:\n"
	message += assignEmail.join ','
	message += '\n' + completeEmail.join ','
	console.log message
	server.send {
		from:'MaintBot <cyopticsmexico@gmail.com>'
		to:"aldo.mendez@avagotech.com, jorge.herrera@avagotech.com"
		subject:'Mantenimientos pendientes'
		text:"#{message}"
	}, (err, message)->
		# console.log "Error: #{err}" or "Message: #{message}"


# para enviar el correo solo tengo que ejecutar
# node ./js/email.js