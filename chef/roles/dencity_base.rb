name "dencity_base"
description "Install and configure dencity base on a single machine"

run_list([
             "recipe[dencity]"
         ])

override_attributes(
    nginx: {
        default_site_enabled: false
    }
)