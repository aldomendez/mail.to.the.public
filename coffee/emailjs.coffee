emailjs = require 'emailjs'
getJSON = require 'get-json-plz'
_ = require 'underscore'
# PushOver notifications
Push = require( 'pushover-notifications' );

push = new Push( {
    user: process.env['PUSHOVER_USER']
    token: process.env['PUSHOVER_TOKEN']
});

msg = {
    message: 'Mantenimientos',   # required
}

sendPush = (message)->
	msg =
		message : message
  title : "Mantenimientos"
		sound : 'tugboat'
		priority : 0
	push.send msg, ( err, result )-> 
	  if ( err )
	    throw err;
	  console.log( result );

server = emailjs.server.connect {
	user: 'cyopticsmexico@gmail.com'
	password:'kerberos86'
	host:'smtp.gmail.com'
	# ssl:false
	tls: true
	port:587
}

unasigned = []

getJSON 'http://jupiter.avagotech.net/apps/qa/maint-dev/toolbox/toolbox.php?action=getAllPending',(err, res)->
	# Ya que tengo los datos, tengo que filtrar por ASIGNADOS Y NO ASIGNADOS
	# Despues a los que no esten asignados, les tengo que enviar un correo a los Supervisores, anunciando los mantenimientos que estan pendientes de asignar
	# Y enviar las notificaciones a los usuarios que tienen mantenimientos pendientes
	maint_oper = _.groupBy(res, 'MAINT_OPER')

	sendPush "Se enviaran ~#{_.size(maint_oper) - 1} correos"
	
	_.map maint_oper , (el, name)->
		unasigned.push {'name':name,'email':el[0].EMAIL,'supervisor':el[0].SUPERVISOR} if !el[0].EMAIL? and name isnt 'null' and name isnt 'g_tejeda'
		if name isnt 'null' and el[0].EMAIL?
			# Esta parte se ejecuta cuando 'name' (el nombre de la persona que tiene asignado el mantenimiento),
			# no es 'null', o sea que alguien lo tiene asignado.
			email = el[0].EMAIL
			supervisor = el[0].SUPERVISOR
			Message =_.template("<%= name %>\n\n 
				Tienes [<%= maint.length%>] mantenimientos asignados, 
				mismos que tienes que completar durante la semana:\n\n
				<% _.each(maint, function(single) {%><%= single.MAINT_ID %>: <%= single.E_DESC %>\n <% });%>\n\n\n
				Si tienes problemas para completar los mantenimientos dirigete con #{supervisor}\n
				Para cerrar revisar y completar tus mantenimientos: http://jupiter.avagotech.net/apps/qa/maintenance/login.php
				Si tu correo '<%=maint[0].EMAIL%>' no corresponde con la cuenta '<%= name %>' envia un correo a
				aldo.mendez@avagotech.com para hacer la correccion")({maint:el, name:name})
			# console.log Message


			#  Quitar el comentario:
			server.send {
				from:'MaintBot <cyopticsmexico@gmail.com>'
				to:"#{email}"
				subject:'Mantenimientos'
				text:Message
			}, (err, message)->
				console.log "Error: #{err}" if err
				console.log "Message: #{message}" if message


		if name is 'null'
			# Esta parte se ejecuta cuando name es 'null', o sea que no se le a asignado a nadie

			supervisorGrp = _.groupBy( el,'SUPERVISOR')

			sendPush " se enviaran #{_.size supervisorGrp} correos a supervisores"

			_.map supervisorGrp , (el, name)->
				# Lo agrupo por supervisor para que a cada supervisor le lleguen los mantenimientos que tienen en sus cuentas
				# y no han asignado.
				email = el[0].SUP_EMAIL
				Message =_.template("<%= maint[0].SUPERVISOR %>\n\n 
					Tienes [<%= maint.length%>] mantenimientos pendientes de asignar, 
					asignalos a la brevedad posible:\n\n
					<% _.each(maint, function(single) {%><%= single.MAINT_ID %>: <%= single.E_DESC %>\n <% });%>\n\n\n
					Asigna  tus mantenimientos en la siguiente direccion: http://jupiter.avagotech.net/apps/qa/maint/index.php
					Si tu correo '<%=maint[0].SUP_EMAIL%>' no corresponde con la cuenta '<%= name %>' envia un correo a
					aldo.mendez@avagotech.com para hacer la correccion")({maint:el, name:name})
				# console.log Message

				# Quitar el comentario:
				server.send {
					from:'MaintBot <cyopticsmexico@gmail.com>'
					to:"aldo.mendez@avagotech.com,#{email}"
					subject:'Mantenimientos'
					text:Message
				}, (err, message)->
					console.log "Error: #{err}" if err
					console.log "Message: #{message}" if message

	console.log unasigned
	if unasigned.length is 0 then unasigned.push 'Todos los usuarios estan capturados'

	sendPush "#{JSON.stringify(unasigned)}"


	# server.send {
	# 	from:'MaintBot <cyopticsmexico@gmail.com>'
	# 	to:"aldo.mendez@avagotech.com"
	# 	subject:'Mantenimientos: faltantes para capturar'
	# 	text:"#{JSON.stringify(unasigned)}"
	# }, (err, message)->
	# 	console.log "Error: #{err}" if err
	# 	console.log "Message: #{message}" if message


# para enviar el correo solo tengo que ejecutar
# node ./js/email.js