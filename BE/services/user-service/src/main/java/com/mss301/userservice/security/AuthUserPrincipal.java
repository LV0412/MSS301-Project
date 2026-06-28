package com.mss301.userservice.security;

import java.util.Collection;
import java.util.List;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

@Getter
public class AuthUserPrincipal implements UserDetails {

    private final Long accountId;
    private final String email;
    private final String role;
    private final List<GrantedAuthority> authorities;

    public AuthUserPrincipal(Long accountId, String email, String role) {
        this.accountId = accountId;
        this.email = email;
        this.role = role;
        this.authorities = List.of(new SimpleGrantedAuthority("ROLE_" + role));
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return "";
    }

    @Override
    public String getUsername() {
        return email;
    }
}
