//
//  ContentView.swift
//  LiWake
//
//  Created by Qiandao Liu on 11/1/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedMode: AlarmMode = .sound
    @State private var selectedTimePeriod = "AM"
    @State private var selectedHour = 1
    @State private var selectedMinute = 0
    @State private var selectedRingtone = "Default"
    @State private var selectedRepeat = "Once"
    @State private var alarmList: [Alarm] = []
    @State private var showSettings = false
    @State private var showAbout = false
    @State private var isSleeping = false  // 用于控制跳转到 SleepingView


    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                ZStack {
                    // 左侧模式切换标签
                    Button(action: {
                        selectedMode = .sound
                    }) {
                        Text("Sound Alarm")
                            .fontWeight(.bold)
                            .padding()
                            .background(selectedMode == .sound ? Color.blue.opacity(0.3) : Color.clear)
                            .cornerRadius(8)
                    }
                    .position(x: width * 0.1, y: height * 0.45)
                    
                    Button(action: {
                        selectedMode = .light
                    }) {
                        Text("Light Alarm")
                            .fontWeight(.bold)
                            .padding()
                            .background(selectedMode == .light ? Color.yellow.opacity(0.3) : Color.clear)
                            .cornerRadius(8)
                    }
                    .position(x: width * 0.1, y: height * 0.55)
                    
                    // 时间选择器
                    HStack(spacing: 10) {
                        Picker("AM/PM", selection: $selectedTimePeriod) {
                            Text("AM").tag("AM")
                            Text("PM").tag("PM")
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 100)
                        
                        Picker("Hour", selection: $selectedHour) {
                            ForEach(1...12, id: \.self) { Text("\($0) H") }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 100)
                        
                        Picker("Minute", selection: $selectedMinute) {
                            ForEach(0..<60) { Text(String(format: "%02d M", $0)) }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 100)
                    }
                    .position(x: width * 0.5, y: height * 0.3)
                    
                    // 铃声和重复选项
                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Ringtone")
                                .font(.headline)
                            Picker("Ringtone", selection: $selectedRingtone) {
                                Text("Default").tag("Default")
                                Text("Chime").tag("Chime")
                                Text("Birdsong").tag("Birdsong")
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Repeat")
                                .font(.headline)
                            Picker("Repeat", selection: $selectedRepeat) {
                                Text("Once").tag("Once")
                                Text("Daily").tag("Daily")
                                Text("Workdays").tag("Workdays")
                                Text("Days off").tag("Days off")
                                Text("Custom").tag("Custom")
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                    .position(x: width * 0.5, y: height * 0.55)
                    
                    // 设置闹钟按钮
                    Button(action: {
                        let newAlarm = Alarm(timePeriod: selectedTimePeriod, hour: selectedHour, minute: selectedMinute, ringtone: selectedRingtone, repeatOption: selectedRepeat)
                        alarmList.append(newAlarm)
                    }) {
                        Text("Set Alarm")
                            .font(.headline)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .position(x: width * 0.5, y: height * 0.65)
                    
                    // 显示设定的闹钟列表
                    ScrollView {
                        ForEach(alarmList) { alarm in
                            Text("\(alarm.displayTime()) - \(alarm.repeatOption)")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .frame(width: 400, height: 300)
                    .position(x: width * 0.9, y: height * 0.5)
                    
                    // 右上角设置和关于按钮
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "gearshape")
                            .font(.title)
                            .padding()
                    }
                    .sheet(isPresented: $showSettings) {
                        SettingView()
                    }
                    .position(x: width * 0.9, y: height * 0.03)
                    
                    Button(action: { showAbout.toggle() }) {
                        Image(systemName: "info.circle")
                            .font(.title)
                            .padding()
                    }
                    .sheet(isPresented: $showAbout) {
                        AboutView()
                    }
                    .position(x: width * 0.95, y: height * 0.03)
                    
                    // 开始睡觉按钮
                    Button(action: {
                        isSleeping = true
                    }) {
                        Text("Start Sleeping")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .position(x: width * 0.9, y: height * 0.9)
                }
                .background(selectedMode == .sound ? Color(Color.ownOffWhiteTran) : Color(Color.ownWhite))
                .navigationDestination(isPresented: $isSleeping) {
                    DepthInstructionView()
                }
            }
        }
    }
}

// Helper Enums and Models
enum AlarmMode {
    case sound, light
}

struct Alarm: Identifiable {
    let id = UUID()
    let timePeriod: String
    let hour: Int
    let minute: Int
    let ringtone: String
    let repeatOption: String
    
    func displayTime() -> String {
        return "\(timePeriod) \(hour):\(String(format: "%02d", minute))"
    }
}

#Preview(traits: .landscapeRight) {
    ContentView()
}

