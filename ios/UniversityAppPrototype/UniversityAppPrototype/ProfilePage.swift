//
//  ProfilePage.swift
//  UniversityAppPrototype
//
//  Created by Ihor Melashchenko on 31/10/2025.
//

import SwiftUI

struct ProfilePage: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            Toggle(isOn: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Is On@*/.constant(true)/*@END_MENU_TOKEN@*/) {
                Text("Weather Updates")
            }
            
            Divider()
            
            HStack {
                Text("Light/Dark Model")
                
                Spacer()
                
                Picker(selection: /*@START_MENU_TOKEN@*/.constant(1)/*@END_MENU_TOKEN@*/, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                    Text("Auto").tag(1)
                    Text("Light").tag(2)
                    Text("Dark").tag(3)
                }
            }
            
            Spacer()
            
            Spacer()
            
            Spacer()
            
            Spacer()
            
            Spacer()
            
            Spacer()
            
            Spacer()
            
            Spacer()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Gradient(colors: backgroundColor))
    }
}

#Preview {
    ProfilePage()
}
