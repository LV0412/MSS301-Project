package com.mss301.authservice.security;

import com.mss301.authservice.domain.AccountStatus;
import com.mss301.authservice.domain.UserAccount;
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
    private final String password;
    private final boolean emailVerified;
    private final AccountStatus status;
    private final List<GrantedAuthority> authorities;

    public AuthUserPrincipal(UserAccount account) {
        this.accountId = account.getId();
        this.email = account.getEmail();
        this.password = account.getPasswordHash();
        this.emailVerified = account.isEmailVerified();
        this.status = account.getStatus();
        this.authorities = List.of(new SimpleGrantedAuthority("ROLE_" + account.getRole().name()));
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return status != AccountStatus.LOCKED && status != AccountStatus.BANNED;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return status == AccountStatus.ACTIVE && emailVerified;
    }
}
