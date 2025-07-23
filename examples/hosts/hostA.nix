{ ... }:
{
  configuration = { lib, config, ... }: {
    noxa.secrets.def = [{
      module = "test";
      ident = "dummy-key";
      generator.script = "dummy";
      generator.tags = [ "example" ];
    }];
  };
}
