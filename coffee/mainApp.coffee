nodemailer = require 'nodemailer'
# smtpTransport = require 'nodemailer-smtp-transport'


# crea un bojeto reutilizable usando el transpor SMTP
transporter = nodemailer.createTransport {
	# service:'gmail'
	host:'smtp.gmail.com'
	port:'587'
	secure: false
	ignoreTLS: false
	debug : true
	auth:{
		user:'cyopticsmexico@gmail.com'
		pass:'kerberos86'
	}
}

mailOptions = {
	from:'Aldo Mendez <cyopticsmexico@gmail.com>'
	to:'aldo.mendez@avagotech.com'
	subject:'Hello'
	text:'Hola Mundo'
	html:'Hola <b>mundo</b>'
}

transporter.sendMail mailOptions, (error, info)->
	if error
		console.log error
	else
		console.log "Message sent: #{info.response}"
	
#  Notas:
# Para hacer que funcione pense en hacer pruebas con las configuraciones de node
# devido a un error con el que me tope al ejecutar este script:

# ```
# Error: "Error: SSL Error: SELF_SIGNED_CERT_IN_CHAIN"
# ```
# 1. La solucion que proponen es ejecutar el siguiente comando en la terminal: 
# `npm config set strict-ssl false`

# 2. La segunda solucion fue actualizar el `npm` con este comando 
# `npm install npm -g --ca=null` y ademas dice que le tenemos que decir a `npm`
# que utiliza registrados conocidos con `npm config set ca=""`

