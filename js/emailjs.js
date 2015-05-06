// Generated by CoffeeScript 1.7.1
(function() {
  var Push, emailjs, getJSON, msg, push, sendPush, server, unasigned, _;

  emailjs = require('emailjs');

  getJSON = require('get-json-plz');

  _ = require('underscore');

  Push = require('pushover-notifications');

  push = new Push({
    user: process.env['PUSHOVER_USER'],
    token: process.env['PUSHOVER_TOKEN']
  });

  msg = {
    message: 'Mantenimientos'
  };

  sendPush = function(message) {
    msg = {
      message: message,
      title: "Mantenimientos",
      sound: 'tugboat',
      priority: 0
    };
    return push.send(msg, function(err, result) {
      if (err) {
        throw err;
      }
      return console.log(result);
    });
  };

  server = emailjs.server.connect({
    user: 'cyopticsmexico@gmail.com',
    password: 'kerberos86',
    host: 'smtp.gmail.com',
    tls: true,
    port: 587
  });

  unasigned = [];

  getJSON('http://jupiter.avagotech.net/apps/qa/maint-dev/toolbox/toolbox.php?action=getAllPending', function(err, res) {
    var maint_oper;
    maint_oper = _.groupBy(res, 'MAINT_OPER');
    sendPush("Se enviaran ~" + (_.size(maint_oper) - 1) + " correos");
    _.map(maint_oper, function(el, name) {
      var Message, email, supervisor, supervisorGrp;
      if ((el[0].EMAIL == null) && name !== 'null' && name !== 'g_tejeda') {
        unasigned.push({
          'name': name,
          'email': el[0].EMAIL,
          'supervisor': el[0].SUPERVISOR
        });
      }
      if (name !== 'null' && (el[0].EMAIL != null)) {
        email = el[0].EMAIL;
        supervisor = el[0].SUPERVISOR;
        Message = _.template("<%= name %>\n\n Tienes [<%= maint.length%>] mantenimientos asignados, mismos que tienes que completar durante la semana:\n\n <% _.each(maint, function(single) {%><%= single.MAINT_ID %>: <%= single.E_DESC %>\n <% });%>\n\n\n Si tienes problemas para completar los mantenimientos dirigete con " + supervisor + "\n Para cerrar revisar y completar tus mantenimientos: http://jupiter.avagotech.net/apps/qa/maintenance/login.php Si tu correo '<%=maint[0].EMAIL%>' no corresponde con la cuenta '<%= name %>' envia un correo a aldo.mendez@avagotech.com para hacer la correccion")({
          maint: el,
          name: name
        });
        server.send({
          from: 'MaintBot <cyopticsmexico@gmail.com>',
          to: "" + email,
          subject: 'Mantenimientos',
          text: Message
        }, function(err, message) {
          if (err) {
            console.log("Error: " + err);
          }
          if (message) {
            return console.log("Message: " + message);
          }
        });
      }
      if (name === 'null') {
        supervisorGrp = _.groupBy(el, 'SUPERVISOR');
        sendPush(" se enviaran " + (_.size(supervisorGrp)) + " correos a supervisores");
        return _.map(supervisorGrp, function(el, name) {
          email = el[0].SUP_EMAIL;
          Message = _.template("<%= maint[0].SUPERVISOR %>\n\n Tienes [<%= maint.length%>] mantenimientos pendientes de asignar, asignalos a la brevedad posible:\n\n <% _.each(maint, function(single) {%><%= single.MAINT_ID %>: <%= single.E_DESC %>\n <% });%>\n\n\n Asigna  tus mantenimientos en la siguiente direccion: http://jupiter.avagotech.net/apps/qa/maint/index.php Si tu correo '<%=maint[0].SUP_EMAIL%>' no corresponde con la cuenta '<%= name %>' envia un correo a aldo.mendez@avagotech.com para hacer la correccion")({
            maint: el,
            name: name
          });
          return server.send({
            from: 'MaintBot <cyopticsmexico@gmail.com>',
            to: "aldo.mendez@avagotech.com," + email,
            subject: 'Mantenimientos',
            text: Message
          }, function(err, message) {
            if (err) {
              console.log("Error: " + err);
            }
            if (message) {
              return console.log("Message: " + message);
            }
          });
        });
      }
    });
    console.log(unasigned);
    if (unasigned.length === 0) {
      unasigned.push('Todos los usuarios estan capturados');
    }
    return sendPush("" + (JSON.stringify(unasigned)));
  });

}).call(this);

//# sourceMappingURL=emailjs.map
