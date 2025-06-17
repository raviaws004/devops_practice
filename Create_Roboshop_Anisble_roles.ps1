# Define base directory
$baseDir = "ansible-roboshop-roles"

# List of paths to create
$directories = @(
    "$baseDir",
    "$baseDir/inventory",
    "$baseDir/inventory/group_vars",
    "$baseDir/roles",
    "$baseDir/roles/common",
    "$baseDir/roles/common/tasks",
    "$baseDir/roles/common/handlers",
    "$baseDir/roles/common/templates",
    "$baseDir/roles/common/files",
    "$baseDir/roles/common/defaults",
    "$baseDir/roles/common/vars",

    "$baseDir/roles/web",
    "$baseDir/roles/web/tasks",
    "$baseDir/roles/web/handlers",
    "$baseDir/roles/web/templates",
    "$baseDir/roles/web/files",
    "$baseDir/roles/web/defaults",
    "$baseDir/roles/web/vars",

    "$baseDir/roles/catalogue",
    "$baseDir/roles/catalogue/tasks",
    "$baseDir/roles/catalogue/handlers",
    "$baseDir/roles/catalogue/templates",
    "$baseDir/roles/catalogue/files",
    "$baseDir/roles/catalogue/defaults",
    "$baseDir/roles/catalogue/vars",

    "$baseDir/roles/user",
    "$baseDir/roles/user/tasks",
    "$baseDir/roles/user/handlers",
    "$baseDir/roles/user/templates",
    "$baseDir/roles/user/files",
    "$baseDir/roles/user/defaults",
    "$baseDir/roles/user/vars",

    "$baseDir/roles/cart",
    "$baseDir/roles/cart/tasks",
    "$baseDir/roles/cart/handlers",
    "$baseDir/roles/cart/templates",
    "$baseDir/roles/cart/files",
    "$baseDir/roles/cart/defaults",
    "$baseDir/roles/cart/vars",

    "$baseDir/roles/shipping",
    "$baseDir/roles/shipping/tasks",
    "$baseDir/roles/shipping/handlers",
    "$baseDir/roles/shipping/templates",
    "$baseDir/roles/shipping/files",
    "$baseDir/roles/shipping/defaults",
    "$baseDir/roles/shipping/vars",

    "$baseDir/roles/payment",
    "$baseDir/roles/payment/tasks",
    "$baseDir/roles/payment/handlers",
    "$baseDir/roles/payment/templates",
    "$baseDir/roles/payment/files",
    "$baseDir/roles/payment/defaults",
    "$baseDir/roles/payment/vars",

    "$baseDir/roles/dispatch",
    "$baseDir/roles/dispatch/tasks",
    "$baseDir/roles/dispatch/handlers",
    "$baseDir/roles/dispatch/templates",
    "$baseDir/roles/dispatch/files",
    "$baseDir/roles/dispatch/defaults",
    "$baseDir/roles/dispatch/vars",

    "$baseDir/roles/mongodb",
    "$baseDir/roles/mongodb/tasks",
    "$baseDir/roles/mongodb/handlers",
    "$baseDir/roles/mongodb/templates",
    "$baseDir/roles/mongodb/files",
    "$baseDir/roles/mongodb/defaults",
    "$baseDir/roles/mongodb/vars",

    "$baseDir/roles/mysql",
    "$baseDir/roles/mysql/tasks",
    "$baseDir/roles/mysql/handlers",
    "$baseDir/roles/mysql/templates",
    "$baseDir/roles/mysql/files",
    "$baseDir/roles/mysql/defaults",
    "$baseDir/roles/mysql/vars",

    "$baseDir/roles/redis",
    "$baseDir/roles/redis/tasks",
    "$baseDir/roles/redis/handlers",
    "$baseDir/roles/redis/templates",
    "$baseDir/roles/redis/files",
    "$baseDir/roles/redis/defaults",
    "$baseDir/roles/redis/vars",

    "$baseDir/roles/rabbitmq",
    "$baseDir/roles/rabbitmq/tasks",
    "$baseDir/roles/rabbitmq/handlers",
    "$baseDir/roles/rabbitmq/templates",
    "$baseDir/roles/rabbitmq/files",
    "$baseDir/roles/rabbitmq/defaults",
    "$baseDir/roles/rabbitmq/vars"

)

# Create directory structure
foreach ($directory in $directories) {
    if (-Not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory | Out-Null
    }
}

# Create files
New-Item "$baseDir/ansible.cfg" -ItemType File | Out-Null
New-Item "$baseDir/playbook.yml" -ItemType File | Out-Null
New-Item "$baseDir/README.md" -ItemType File | Out-Null
New-Item "$baseDir/inventory/hosts" -ItemType File | Out-Null
New-Item "$baseDir/inventory/group_vars/all.yml" -ItemType File | Out-Null

# create files for main, handlers, defaults, etc.
foreach ($role in @("common","web","catalogue","user","cart","shipping","payment","dispatch","mongodb","mysql","redis","rabbitmq")) {
    New-Item "$baseDir/roles/$role/tasks/main.yml" -ItemType File | Out-Null
    New-Item "$baseDir/roles/$role/handlers/main.yml" -ItemType File | Out-Null
    New-Item "$baseDir/roles/$role/defaults/main.yml" -ItemType File | Out-Null
    New-Item "$baseDir/roles/$role/vars/main.yml" -ItemType File | Out-Null
}

# create additional files
New-Item "$baseDir/roles/web/templates/nginx.conf.j2" -ItemType File | Out-Null
New-Item "$baseDir/roles/web/templates/web.service.j2" -ItemType File | Out-Null
New-Item "$baseDir/roles/web/files/roboshop.conf" -ItemType File | Out-Null

New-Item "$baseDir/roles/catalogue/templates/catalogue.service.j2" -ItemType File | Out-Null
New-Item "$baseDir/roles/catalogue/files/catalogue.zip" -ItemType File | Out-Null

New-Item "$baseDir/roles/user/templates/user.service.j2" -ItemType File | Out-Null
New-Item "$baseDir/roles/user/files/user.zip" -ItemType File | Out-Null

New-Item "$baseDir/roles/cart/templates/cart.service.j2" -ItemType File | Out-Null
New-Item "$baseDir/roles/cart/files/cart.zip" -ItemType File | Out-Null

New-Item "$baseDir/roles/shipping/templates/shipping.service.j2" -ItemType File | Out-Null
New-Item "$baseDir/roles/shipping/files/shipping.zip" -ItemType File | Out-Null

New-Item "$baseDir/roles/payment/templates/payment.service.j2" -ItemType File | Out-Null
New-Item "$baseDir/roles/payment/files/payment.zip" -ItemType File | Out-Null

New-Item "$baseDir/roles/dispatch/templates/dispatch.service.j2" -ItemType File | Out-Null
New-Item "$baseDir/roles/dispatch/files/dispatch.zip" -ItemType File | Out-Null

New-Item "$baseDir/roles/mongodb/templates/mongod.conf.j2" -ItemType File | Out-Null
New-Item "$baseDir/roles/mongodb/files/mongodb.repo" -ItemType File | Out-Null

New-Item "$baseDir/roles/mysql/templates/my.cnf.j2" -ItemType File | Out-Null
New-Item "$baseDir/roles/mysql/files/schema.sql" -ItemType File | Out-Null

New-Item "$baseDir/roles/redis/templates/redis.conf.j2" -ItemType File | Out-Null
New-Item "$baseDir/roles/redis/files/redis.repo" -ItemType File | Out-Null
