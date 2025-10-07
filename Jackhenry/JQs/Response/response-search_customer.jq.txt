{ 
    apiSuccess: .apiSuccess,
    errors: { 
        errorNum: (if (.errors.errorNum != "" and .errors.errorNum != null) then .errors.errorNum else null end),
        errorMsg: ((if (.errors.errorNum != "" and .errors.errorNum != null) then .errors.errorMsg.Error else null end))
    },
    responses: (if .apiSuccess == true and .responses.Id 
        then [{ 
            cif: .responses.Id
        }] 
        else null 
        end
    )
}