# Custom Routing
This module allows you to add external modules to the Nginx managed by Control.

### Example
```nix
custom-routing.entries = [
    {
        subdomain = "btop";
        port = 7681;
        basicAuth = { # optional, to password protect the module
            username = "password";
        };
    }
    # ... -> can add any number of modules here
];
```

This example creates a subdomain redirecting to the desired port