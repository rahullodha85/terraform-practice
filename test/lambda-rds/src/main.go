package main

import (
	"fmt"

	//	"fmt"
	"context"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"gorm.io/driver/sqlserver"
	"gorm.io/gorm"
)

func main() {
	log.Printf("Start Lambda")
	lambda.Start(Handler)
}

type MyEvent map[string]interface{}

func Handler(ctx context.Context, event MyEvent) (events.APIGatewayProxyResponse, error) {
	for k, v := range event {
		log.Printf("KEY: %v, VALUE: %v", k, v)
	}
	// github.com/denisenkom/go-mssqldb
//	dsn := "sqlserver://admin:test1234567890@database-1.cgu1i6innl6a.us-east-1.rds.amazonaws.com:1433"
    dns := fmt.Sprintf("sqlserver://%v:%v@%v:%v", event["username"].(string), event["password"].(string), event["sqlHost"].(string), event["port"].(float64))
    log.Printf("DNS: %v", dns)
	db, err := gorm.Open(sqlserver.Open(dns), &gorm.Config{})
	if err != nil {
		fmt.Println(err.Error())
	}
	var result []Result
    GetUsers(db, &result)
    for _, item := range result {
        fmt.Println(item)
    }
	//
	//     user := User{
	//         Login:    "test_user",
	//         Password: "test1234567890",
	//         }
	//         CreateUser(user, db)
	//     GetUsers(db, &result)
	//     for _, item := range result {
	//         fmt.Println(item)
	//     }
	//
	//     DeleteUser(user, db)
	//     GetUsers(db, &result)
	//     for _, item := range result {
	//         fmt.Println(item)
	//     }
	//
	return events.APIGatewayProxyResponse{
		Body:       "Hello world",
		StatusCode: 200,
	}, nil
}

func GetUsers(db *gorm.DB, result *[]Result) {
	db.Raw(`select sp.name as Login,
    sp.type_desc as Login_type,
    case when sp.is_disabled = 1 then 'Disabled'
    else 'Enabled' end as Status
    from sys.server_principals sp
    left join sys.sql_logins sl
    on sp.principal_id = sl.principal_id
    where sp.type not in ('G', 'R')
    order by sp.name;`, 3).Scan(&result)
}

//func CreateUser(user User, db *gorm.DB) {
//	sqlQuery := fmt.Sprintf(`use master
//CREATE LOGIN %v WITH PASSWORD = '%v';`, user.Login, user.Password)
//	fmt.Printf("Executing query: %v", sqlQuery)
//    db.Exec(sqlQuery)
//}
//
//func DeleteUser(user User, db *gorm.DB) {
//    sqlQuery := fmt.Sprintf(`drop login %v;`, user.Login)
//    fmt.Printf("Executing query: %v", sqlQuery)
//    db.Exec(sqlQuery)
//}
//
type Result struct {
	Login      string
	Login_type string
	Status     string
}

type User struct {
	Login    string
	Password string
}
