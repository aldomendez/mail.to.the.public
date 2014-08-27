// Generated by CoffeeScript 1.7.1
(function() {
  var emailjs, getJSON, server, unasigned, _;

  emailjs = require('emailjs');

  getJSON = require('get-json-plz');

  _ = require('underscore');

  server = emailjs.server.connect({
    user: 'cyopticsmexico@gmail.com',
    password: 'kerberos86',
    host: 'smtp.gmail.com',
    tls: true,
    port: 587
  });

  unasigned = [];

  getJSON('http://jupiter.avagotech.net/apps/qa/maint-dev/toolbox/toolbox.php?action=getAllPending', function(err, res) {
    _.map(_.groupBy(res, 'MAINT_OPER'), function(el, name) {
      var Message, email, supervisor;
      if (el[0].EMAIL == null) {
        unasigned.push("hello " + name + " my email is " + el[0].EMAIL + ", supervisor " + el[0].SUPERVISOR);
      }
      if (name !== 'null' && (el[0].EMAIL != null)) {
        email = el[0].EMAIL;
        supervisor = el[0].SUPERVISOR;
        Message = _.template("<%= name %>\n\n Tienes [<%= maint.length%>] mantenimientos asignados, mismos que tienes que completar durante la semana:\n\n <% _.each(maint, function(single) {%><%= single.MAINT_ID %>: <%= single.E_DESC %>\n <% });%>\n\n\n Si tienes problemas para completar los mantenimientos dirigete con " + supervisor + "\n Si tu correo '<%=maint[0].EMAIL%>' no corresponde con la cuenta '<%= name %>' envia un correo a aldo.mendez@avagotech.com para hacer la correccion")({
          maint: el,
          name: name
        });
        console.log(Message);
        server.send({
          from: 'MaintBot <cyopticsmexico@gmail.com>',
          to: "aldo.mendez@avagotech.com," + email,
          subject: 'Mantenimientos',
          text: Message
        }, function(err, message) {});
      }
      if (name === 'null') {
        return _.map(_.groupBy(el, 'SUPERVISOR'), function(el, name) {
          email = el[0].SUP_EMAIL;
          Message = _.template("<%= maint[0].SUPERVISOR %>\n\n Tienes [<%= maint.length%>] mantenimientos pendientes de asignar, asignalos a la brevedad posible:\n\n <% _.each(maint, function(single) {%><%= single.MAINT_ID %>: <%= single.E_DESC %>\n <% });%>\n\n\n Si tu correo '<%=maint[0].SUP_EMAIL%>' no corresponde con la cuenta '<%= name %>' envia un correo a aldo.mendez@avagotech.com para hacer la correccion")({
            maint: el,
            name: name
          });
          console.log(Message);
          return server.send({
            from: 'MaintBot <cyopticsmexico@gmail.com>',
            to: "aldo.mendez@avagotech.com," + email,
            subject: 'Mantenimientos',
            text: Message
          }, function(err, message) {});
        });
      }
    });
    return server.send({
      from: 'MaintBot <cyopticsmexico@gmail.com>',
      to: "aldo.mendez@avagotech.com",
      subject: 'Mantenimientos: faltantes para capturar',
      text: "" + (JSON.stringify(unasigned))
    }, function(err, message) {});
  });

}).call(this);

//# sourceMappingURL=emailjs.map
