(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .directive("sdServiceOfferingsAuthz", ServiceOfferingsAuthzDirective);

    ServiceOfferingsAuthzDirective.$inject = [];

  function ServiceOfferingsAuthzDirective() {
    var directive = {
        bindToController: true,
        controller: ServiceOfferingsAuthzController,
        controllerAs: "vm",
        restrict: "A",
        link: link
    };
    return directive;

    function link(scope, element, attrs) {
      console.log("ServiceOfferingsAuthzDirective", scope);
    }
  }

  ServiceOfferingsAuthzController.$inject = ["$scope",
                                   "spa-demo.subjects.ServiceOfferingsAuthz"];
  function ServiceOfferingsAuthzController($scope, ServiceOfferingsAuthz) {
    var vm = this;
    vm.authz={};
    vm.authz.canUpdateItem = canUpdateItem;
    vm.newItem=newItem;

    activate();
    return;
    //////////
    function activate() {
      vm.newItem(null);
    }

    function newItem(item) {
      ServiceOfferingsAuthz.getAuthorizedUser().then(
        function(user){ authzUserItem(item, user); },
        function(user){ authzUserItem(item, user); });
    }

    function authzUserItem(item, user) {
      console.log("new Item/Authz", item, user);

      vm.authz.authenticated = ServiceOfferingsAuthz.isAuthenticated();
      vm.authz.canQuery      = ServiceOfferingsAuthz.canQuery();
      vm.authz.canCreate = ServiceOfferingsAuthz.canCreate();
      if (item && item.$promise) {
        vm.authz.canUpdate     = false;
        vm.authz.canDelete     = false;
        vm.authz.canGetDetails = false;
        item.$promise.then(function(){ checkAccess(item); });
      } else {
        checkAccess(item)
      }
    }

    function checkAccess(item) {
      vm.authz.canUpdate     = ServiceOfferingsAuthz.canUpdate(item);
      vm.authz.canDelete     = ServiceOfferingsAuthz.canDelete(item);
      vm.authz.canGetDetails = ServiceOfferingsAuthz.canGetDetails(item);
      console.log("checkAccess", item, vm.authz);
    }    

    function canUpdateItem(item) {
      console.log(ServiceOfferingsAuthz.canUpdate(item));
      return ServiceOfferingsAuthz.canUpdate(item);
    }    
  }
})();