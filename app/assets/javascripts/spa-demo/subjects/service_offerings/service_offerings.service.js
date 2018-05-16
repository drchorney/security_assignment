(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .factory("spa-demo.subjects.ServiceOffering", ServiceOfferingFactory);

  ServiceOfferingFactory.$inject = ["$resource", "spa-demo.config.APP_CONFIG"];
  function ServiceOfferingFactory($resource, APP_CONFIG) {
    var service = $resource(APP_CONFIG.server_url + "/api/service_offerings/:id",
      { id: '@id'},
      {
        update: {method: "PUT"},
        save:   {method: "POST", transformRequest: checkEmptyPayload }
      });
    return service;
  }

  //rails wants at least one parameter of the document filled in
  //all of our fields are optional
  //ngResource is not passing a null field by default, we have to force it
  function checkEmptyPayload(data) {
    if (!data['so_name']) {
      data['so_name']=" ";
    } 
    return angular.toJson(data);
  }      
})();