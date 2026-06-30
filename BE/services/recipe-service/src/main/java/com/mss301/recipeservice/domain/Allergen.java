package com.mss301.recipeservice.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "allergens")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Allergen {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "allergen_id")
    private Long allergenId;

    @Column(nullable = false, unique = true, length = 100)
    private String name;
}
