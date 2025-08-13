{
  description = "Home Server Service Modules";

  outputs = { self }: {
  	jellyfin = {
  	  path = "./jellyfin";
  	  description = "jellyfin container";
  	};
  	immich = {
  	  path = "./immich";
  	  description = "immich container";
  	};
  	transmission = {
  	  path = "./transmission";
  	  description = "transmission container";
  	};
  };
}
