from pathlib import Path

p=Path('lib/catalog/signup_required.dart')
s=p.read_text()
old="""    await _ensureLocation();
    if(!mounted)return;
    Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>ShowcaseShellPage(customerName:n.isEmpty?'Cliente':n,phone:p)));
"""
new="""    final pos=await _ensureLocation();
    try{
      if(p.isNotEmpty){
        await Supabase.instance.client.rpc('register_app_user',params:{
          'p_phone':p,
          'p_full_name':n.isEmpty?'Cliente':n,
          'p_latitude':pos?.latitude,
          'p_longitude':pos?.longitude,
        });
      }
    }catch(_){ }
    if(!mounted)return;
    Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>ShowcaseShellPage(customerName:n.isEmpty?'Cliente':n,phone:p)));
"""
if old not in s: raise SystemExit('entry finish marker not found')
s=s.replace(old,new,1)
p.write_text(s)
print('App user tracking enabled')
