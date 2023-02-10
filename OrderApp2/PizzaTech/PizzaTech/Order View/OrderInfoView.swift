//
//  OrderInfoView.swift
//  PizzaTech
//
//  Created by Léon Becker on 13.06.21.
//

import SwiftUI

struct ProgressCircleView: View {
    var progress: Int
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: CGFloat(Double(1) - (Double(progress) / Double(100))), to: 1)
                .stroke(
                    LinearGradient(gradient: Gradient(colors: [Color(.red), Color(.blue)]), startPoint: .leading, endPoint: .bottomLeading),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round, miterLimit: .infinity, dash: [20, 0], dashPhase: 0))
                .rotationEffect(.degrees(90))
                .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
                .frame(width: 200, height: 200)
                .shadow(color: Color(.blue).opacity(0.1), radius: 3, x: 0, y: 3)

            Text("\(progress)%")
                .bold()
                .font(.title)
                .animation(nil)
    
        }
        .padding(28)
        .background(Circle().foregroundColor(.white).shadow(radius: 10))
    }
}

struct OrderInfoView: View {
    var realOrder: RealOrder
    var decodedPizzasOrdered: [OrderRequestItem]
    
    @State var orderProgress = 0
    
    let time = Timer.publish(every: 3, on: .main, in: .default).autoconnect()
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text("Fortschritt")
                    .bold()
                    .font(.title3)
                    .padding([.leading], 23)
                
                Spacer()
            }
            ProgressCircleView(progress: orderProgress)
                .padding(.top, 30)
            
            Text(getProgressText())
                .bold()
                .foregroundColor(getProgressColor())
                .font(.title)
                .frame(maxWidth: .infinity)
                .padding([.top, .bottom], 10)
                .background(Color.white.cornerRadius(15).shadow(radius: 10))
                .padding(.top, 40)
                .padding([.leading, .trailing], 16)
                .multilineTextAlignment(.center)
                .animation(nil)
            
            Spacer()
        }
        .padding(.top, 25)
        .navigationTitle("Deine Bestellung")
        .onAppear { pollProgress() }
        .onReceive(time) { _ in
            pollProgress()
        }
    }
    
    func getProgressColor() -> Color {
        if orderProgress == 0 {
            return Color.red
        } else if orderProgress > 0 && orderProgress <= 15 {
            return Color.orange
        } else if orderProgress > 15 && orderProgress <= 70 {
            return Color.yellow
        } else if orderProgress > 70 && orderProgress < 100 {
            return Color(red: 0.74, green: 0.84, blue: 0.65)
        } else if orderProgress == 100 {
            return Color.green
        } else {
            return Color.black
        }
    }
    
    func getProgressText() -> String {
        if orderProgress == 0 {
            return "Bestellung erhalten"
        } else if orderProgress > 0 && orderProgress <= 15 {
            return "Bestellung in Warteschlange"
        } else if orderProgress > 15 && orderProgress <= 70 {
            return "Wird frisch zubereitet"
        } else if orderProgress > 70 && orderProgress < 100 {
            return "Auf dem Weg zu dir"
        } else if orderProgress == 100 {
            return "Geliefert\nLass es dir schmecken!"
        } else {
            return "Wird bearbeitet"
        }
    }
    
    func pollProgress() {
        var request = URLRequest(url: URL(string: "https://www.space8.me:7392/order/get/progress/")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.httpBody = """
        {"order_id": "\(realOrder.orderID)"}
        """.data(using: .utf8)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: request) { data, request, error in
            let decoder = JSONDecoder()
            var orderProgressAll: OrderProgressResponse? = nil
            do {
                orderProgressAll = try decoder.decode(OrderProgressResponse.self, from: data!)
            } catch {
                fatalError("Couldn't decode order progress response.")
            }
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.5)) {
                    orderProgress = orderProgressAll!.order_progress
                }
            }
            semaphore.signal()
        }.resume()
        semaphore.wait()
    }
}

struct OrderProgressResponse: Decodable {
    var order_progress: Int
}

struct OrderInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressCircleView(progress: 100)
    }
}
