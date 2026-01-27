//
//  StudentIDBack.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 23/01/2026.
//

import SwiftUI

struct StudentIDBack: View {
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 40)
                .frame(width: 325, height: 500)
                .opacity(0.3)
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 40))
            
            VStack(alignment: .leading) {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Text("Expires in 1:59 minutes")
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 40)
                        .frame(width: 250, height: 250)
                        .opacity(0.3)
                    
                    Spacer()
                }
                
                Spacer()
                
                Picker(selection: /*@START_MENU_TOKEN@*/.constant(1)/*@END_MENU_TOKEN@*/, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                    Text("QR-Code").tag(1)
                    Text("Barcode").tag(2)
                }
                .pickerStyle(.segmented)
                
                Spacer()
            }
            .padding(20)
            .frame(width: 325, height: 500)
        }
    }
}

#Preview {
    StudentIDBack()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Gradient(colors: backgroundColor))
}
