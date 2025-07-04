module ErrorMessages
  class Password
    NOT_CONFIRMED = "needs to be confirmed"
    MISSMATCH = "and the confirmation of the password does not match"
    TOO_SHORT = "needs to be at least <b>6 characters</b> long"
    TOO_LONG = "can't be more than <b>30 characters</b> long"
  end
  
  class Login
    NOT_CONFIRMED = "needs to be confirmed"
    USED = "has already been taken"
    MISSMATCH = "and the confirmation of the email does not match"
    NOT_VALID = "is not a valid address"
    NONE_EXISTING = "is not a registered email address"
  end
  
  class Misc
    TERMS_OF_SERVICE = "Please agree to the Terms of Service"
    BLANK_ROLE = "can't be blank"
  end
end
