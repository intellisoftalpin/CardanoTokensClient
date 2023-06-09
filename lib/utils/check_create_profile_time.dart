
bool createTimeCheck(DateTime createTime, DateTime lastEnterTime){
  bool requestPass = false;
  DateTime now = DateTime.now();
  int timePosition = now.difference(createTime).inMinutes;
  print('Registration time in minutes: $timePosition');
  if (timePosition <= 20160){
    int diff = now.difference(lastEnterTime).inMinutes;
    print('Time diff in minutes: $diff');
    if (diff > 4320){
      requestPass = true;
    } else {
      requestPass = false;
    }
  } else if (timePosition > 20160 && timePosition <= 106560){
    int diff = now.difference(lastEnterTime).inMinutes;
    print('Time diff in minutes: $diff');
    if(diff > 10080){
      requestPass = true;
    } else {
      requestPass = false;
    }
  } else {
    int diff = now.difference(lastEnterTime).inMinutes;
    if(diff > 20160){
      requestPass = true;
    } else {
      requestPass = false;
    }
    print('Time diff in minutes: $diff');
  }
  return requestPass;
}