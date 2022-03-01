//
//  ContentView.swift
//  LoginUI
//
//  Created by Ian Solomein on 15.08.2020.
//  Copyright © 2020 Ian Solomein. All rights reserved.
//



import SwiftUI
import Firebase
import FirebaseAuth


struct ContentView: View {

    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false

    var body: some View {

        VStack {

            if status {
                Home()
            } else {
                SignIn()
            }
        }
        .animation(.spring())
        .onAppear {

            NotificationCenter.default.addObserver(forName: NSNotification.Name("statusChange"), object: nil, queue: .main) { (_) in

                let status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
                self.status = status
            }
        }
    }
}

struct Home: View {

    var body: some View {

        VStack {

            Text("Home")

            Button(action: {
                UserDefaults.standard.set(false, forKey: "status")
                NotificationCenter.default.post(name: Notification.Name("statusChange"), object: nil)
            }) {
                Text("Logout")
            }
        }
    }
}

struct SignIn: View {

    var colorOne = #colorLiteral(red: 1, green: 0.7213855386, blue: 0.09071082622, alpha: 1)

    @State var user = ""
    @State var pass = ""
    @State var message = ""
    @State var alert = false
    @State var show = false



    var body: some View {
        VStack {
            Text("Sing in")
                .fontWeight(.heavy)
                .font(.largeTitle)
                .padding([.top,.bottom], 20)

            // User name + password
            VStack {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("Username")
                            .font(.headline)
                            .fontWeight(.light)
                            .foregroundColor(Color.init(.label).opacity(0.75))
                    }

                    HStack {

                        TextField("Enter Your Username", text: $user)

                        if user != ""{
                            Image("check").foregroundColor(Color.init(.label))
                        }
                    }
                    Divider()
                }
                .padding(.bottom, 15)

                VStack(alignment: .leading){

                    Text("Password")
                        .font(.headline)
                        .fontWeight(.light)
                        .foregroundColor(Color.init(.label).opacity(0.75))

                    SecureField("Enter Your Password", text: $pass)

                    Divider()
                }
            }
            .padding(.horizontal, 6)

            // Sing in
            VStack {
                Button(action: {

                    singInWithEmail(email: self.user, password: self.pass) { (verified, status) in

                        if !verified {
                            self.message = status
                            self.alert.toggle()
                        } else {
                            UserDefaults.standard.set(true, forKey: "status")
                            NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                        }

                    }

                }) {
                    Text("Sign In")
                        .foregroundColor(.black)
                        .frame(width: UIScreen.main.bounds.width - 250)
                        .padding()
                }
                .background(Color(colorOne))
                .clipShape(Capsule())
                .padding(.top, 45)
                .alert(isPresented: $alert) {

                    Alert(title: Text("Error"), message: Text(self.message), dismissButton: .default(Text("OK")))

                }
            }

            // Sing up
            HStack(spacing: 10) {

                Text("Don't Have An Account ?")
                    .foregroundColor(.gray.opacity(0.5))

                Button(action: {
                    self.show.toggle()
                }) {
                    Text("Sing up")
                }
                .foregroundColor(.blue)
            }
            .padding(.top, 10)
        }
        .sheet(isPresented: $show) {
            SignUp(show: self.show)
        }
    }
}

struct SignUp: View {

    var colorOne = #colorLiteral(red: 1, green: 0.7213855386, blue: 0.09071082622, alpha: 1)

    @State var user = ""
    @State var pass = ""
    @State var message = ""
    @State var alert = false
    @State var show = false
    @Environment(\.presentationMode) var presentationMode


    var body: some View {
        VStack {
            Text("Sing up")
                .fontWeight(.heavy)
                .font(.largeTitle)
                .padding([.top,.bottom], 20)

            // User name + password
            VStack {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("Username")
                            .font(.headline)
                            .fontWeight(.light)
                            .foregroundColor(Color.init(.label).opacity(0.75))
                    }

                    HStack {

                        TextField("Enter Your Username", text: $user)

                        if user != ""{
                            Image("check").foregroundColor(Color.init(.label))
                        }
                    }
                    Divider()
                }
                .padding(.bottom, 15)

                VStack(alignment: .leading){

                    Text("Password")
                        .font(.headline)
                        .fontWeight(.light)
                        .foregroundColor(Color.init(.label).opacity(0.75))

                    SecureField("Enter Your Password", text: $pass)

                    Divider()
                }
            }
            .padding(.horizontal, 6)

            // Sing up
            VStack {
                Button(action: {

                    singUpWithEmail(email: self.user, password: self.pass) { (verified, status) in

                        if !verified {
                            self.message = status
                            self.alert.toggle()
                        } else {
                            UserDefaults.standard.set(true, forKey: "status")
                            NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                        }

                    }

                }) {
                    Text("Sign up")
                        .foregroundColor(.black)
                        .frame(width: UIScreen.main.bounds.width - 250)
                        .padding()
                }
                .background(Color(colorOne))
                .clipShape(Capsule())
                .padding(.top, 45)
                .alert(isPresented: $alert) {

                    Alert(title: Text("Error"), message: Text(self.message), dismissButton: .default(Text("OK")))

                }
            }

            // Sing up
            HStack(spacing: 10) {

                Text("I already have an account.")
                    .foregroundColor(.gray.opacity(0.5))

                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Sing in")
                }
                .foregroundColor(.blue)
            }
            .padding(.top, 10)
        }
        .padding()
    }
}


// Передают инфу в Firebase. Их мы будем использовать для структуры входа и для регистрации приложения.
func singInWithEmail(email: String, password: String, completion: @escaping (Bool, String) -> Void) {

    Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
        if err != nil {
            completion(false,(err?.localizedDescription)!)
            return
        }
        completion(true, (res?.user.email)!)
    }
}


func singUpWithEmail(email: String, password: String, completion: @escaping (Bool, String) -> Void) {

    Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
        if err != nil {
            completion(false,(err?.localizedDescription)!)
            return
        }
        completion(true, (res?.user.email)!)
    }

}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
