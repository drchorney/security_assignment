(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .factory("spa-demo.subjects.ServiceOfferingsAuthz", ServiceOfferingsAuthzFactory);

    ServiceOfferingsAuthzFactory.$inject = ["$q","spa-demo.authz.Authz",
                                "spa-demo.authz.BasePolicy","spa-demo.subjects.Thing"];
  function ServiceOfferingsAuthzFactory($q,Authz, BasePolicy,Thing) {
    function ServiceOfferingsAuthz() {
      BasePolicy.call(this, "ServiceOffering");
    }

      //start with base class prototype definitions
    ServiceOfferingsAuthz.prototype = Object.create(BasePolicy.prototype);
    ServiceOfferingsAuthz.constructor = ServiceOfferingsAuthz;

      //override and add additional methods
      ServiceOfferingsAuthz.prototype.canQuery=function() {
        //console.log("service_offeringsAuthz.canQuery");
        return Authz.isAuthenticated();
      };
  
        //add custom definitions
      ServiceOfferingsAuthz.prototype.canAddImage=function(service_offering) {
          return Authz.isMember(service_offering);
      };
      ServiceOfferingsAuthz.prototype.canUpdateImage=function(service_offering) {
          return Authz.isOrganizer(service_offering)
      };
      ServiceOfferingsAuthz.prototype.canRemoveImage=function(service_offering) {
          return Authz.isOrganizer(service_offering) || Authz.isAdmin();
      };

      ServiceOfferingsAuthz.prototype.canUpdate = function(service_offering) {
        //console.log("BasePolicy.canUpdate", item);
        if (!service_offering) {
          return false;
        } else {
          console.log(service_offering.thing_id);
          // var thing = Thing.get({id:service_offering.thing_id});
          // thing.$promise.then(function(thing){
          //   return Authz.isOrganizer(thing);
          // })
        }
      };

    return new ServiceOfferingsAuthz();
  }
})();