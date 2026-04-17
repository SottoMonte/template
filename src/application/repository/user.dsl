factory:repository := {
    location: {
        "API": [
            "users",
            "users?{% for key, value in filter.eq.items() %}{{ key }}={{ value }}{% if not loop.last %}&{% endif %}{% endfor %}",
            "users/{{filter.eq.id}}",
            "users/{{filter.eq.userId}}/posts?{% for key, value in filter.eq.items() %}{{ key }}={{ value }}{% if not loop.last %}&{% endif %}{% endfor %}",
            "users/{{filter.eq.id}}/albums{% if filter.eq.target_albums %}{% endif %}",
            "users/{{filter.eq.id}}/todos{% if filter.eq.target_todos %}{% endif %}",
            "users?email={{filter['eq']['email']}}",
            "users?username={{filter.eq.user.username}}&website={{filter['eq']['site']}}"
        ]
    };
    
    model: {};
    
    values: {
    };
    
    mapper: {
    };
    
    payloads: {
    };
    
    functions: {
    };
};