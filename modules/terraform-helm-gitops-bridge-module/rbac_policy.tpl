# rbac_policy.tpl
${group_memberships}
${role_assignments}

# Admin permissions
p, role:admin, applications, *, */*, allow
p, role:admin, projects, *, *, allow
p, role:admin, clusters, *, *, allow
p, role:admin, repositories, *, *, allow
p, role:admin, certificates, *, *, allow

# Developer permissions
p, role:developer, applications, get, */*, allow
p, role:developer, applications, sync, */*, allow
p, role:developer, projects, get, *, allow
p, role:developer, logs, get, */*, allow

# Team specific permissions
p, role:team-a-access, applications, *, team-a/*, allow
p, role:team-b-access, applications, *, team-b/*, allow

# Allow all destinations and resources
p, role:admin, *, *, *, allow
