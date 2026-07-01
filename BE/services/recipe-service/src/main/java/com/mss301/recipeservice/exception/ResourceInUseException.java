package com.mss301.recipeservice.exception;

public class ResourceInUseException extends RuntimeException {
    public ResourceInUseException(String resource, Object id) {
        super(resource + " is referenced and cannot be deleted: " + id);
    }
}
