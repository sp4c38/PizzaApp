//
//  CheckoutValidateFields.swift
//  PizzaApp
//
//  Created by Léon Becker on 20.08.20.
//

import Foundation

func checkoutValidateFields(_ orderDetails: OrderDetails) -> (Bool, String) {
    if (orderDetails.firstname != "") && (orderDetails.lastname != "") && (orderDetails.street != "") && (orderDetails.city != "")  && (orderDetails.postalCode != "") {
        if 3...30 ~= orderDetails.firstname.count { // Same as: if (orderDetails.firstname.count <= 3) && (orderDetails.firstname.count <= 30)
            if 3...30 ~= orderDetails.lastname.count {
                if 3...40 ~= orderDetails.street.count {
                    if 2...30 ~= orderDetails.city.count {
                        if 1...5 ~= orderDetails.postalCode.count {
                            return (true, "")
                        } else {
                            return (false, "Ihre Postleitzahl darf höchstens 5 Ziffern lang sein")
                        }
                    } else {
                        return (false, "Ihr Stadtname muss zwischen 2 und 30 Buchstaben lang sein")
                    }
                } else {
                    return (false, "Ihr Straßenname muss zwischen 3 und 40 Buchstaben lang sein")
                }
            } else {
                return (false, "Ihr Nachname muss zwischen 3 und 30 Buchstaben lang sein")
            }
        } else {
            return (false, "Ihr Vorname muss zwischen 3 und 30 Buchstaben lang sein")
        }
    } else {
        return (false, "Bitte füllen Sie alle Felder aus")
    }
}
