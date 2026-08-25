from pathlib import Path

p=Path('lib/catalog/checkout.dart')
s=p.read_text()
if "package:shared_preferences/shared_preferences.dart" not in s:
    s=s.replace("import 'package:flutter/services.dart';", "import 'package:flutter/services.dart';\nimport 'package:shared_preferences/shared_preferences.dart';",1)
old="""  @override
  void initState() {
    super.initState();
    redemptionFuture = widget.repo.valecoinRedemptionPreview(widget.phone, subtotal);
    redemptionFuture.then((value) {
      if (mounted) setState(() => redemption = value);
    });
  }
"""
new="""  @override
  void initState() {
    super.initState();
    redemptionFuture = widget.repo.valecoinRedemptionPreview(widget.phone, subtotal);
    redemptionFuture.then((value) {
      if (mounted) setState(() => redemption = value);
    });
    _restoreLocation();
  }

  Future<void> _restoreLocation() async {
    final prefs=await SharedPreferences.getInstance();
    final lat=prefs.getDouble('zecapao_latitude'),lng=prefs.getDouble('zecapao_longitude');
    if(lat!=null&&lng!=null&&mounted){
      setState(()=>deliveryPoint=DeliveryPoint(lat,lng));
    }
  }
"""
if old not in s: raise SystemExit('checkout initState marker not found')
s=s.replace(old,new,1)
p.write_text(s)
print('Checkout location restored from onboarding')
