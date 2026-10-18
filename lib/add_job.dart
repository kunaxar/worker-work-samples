import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'data.dart';
import 'model.dart';
import 'ui.dart';

class AddJob extends StatefulWidget {
  const AddJob({super.key});
  @override
  State<AddJob> createState() => _AddJobState();
}

class _AddJobState extends State<AddJob> {
  int step = 0;
  TradeDef trade = trades[0];
  String role = 'Apprentice';
  String kind = projectTypes[0];
  final project = TextEditingController();
  final company = TextEditingController();
  String start = '2024', end = '2025';
  bool current = true;
  final tasks = <String>{};
  final custom = TextEditingController();
  final photos = <Photo>[];
  final vname = TextEditingController();
  String vrole = 'Foreman';
  static const years = ['2026', '2025', '2024', '2023', '2022', '2021', '2020', '2019', '2018'];

  bool get canNext {
    if (step == 0) return project.text.trim().isNotEmpty;
    if (step == 1) return tasks.isNotEmpty;
    return true;
  }

  void finish(Vouch v) {
    final j = Job(
      id: 'j${DateTime.now().millisecondsSinceEpoch}', project: project.text.trim(), kind: kind, company: company.text.trim(), trade: trade.name, role: role,
      startYear: start, endYear: end, current: current, tasks: tasks, photos: photos, vouch: v, vouchName: vname.text.trim(), vouchRole: vrole,
    );
    store.add(j);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added. Employers now see ${j.tasks.length} tasks${j.photos.isEmpty ? '' : ' and ${j.photos.length} photo(s)'} for this job.')));
  }

  Future<void> pick() async {
    try {
      final files = await ImagePicker().pickMultiImage(imageQuality: 80);
      for (final f in files) { photos.add(Photo(bytes: await f.readAsBytes())); }
      setState(() {});
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open photos here. Use a sample photo for the demo.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['What was the job?', 'What did you do there?', 'Show it', 'Who can vouch for it?'];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(step == 0 ? Icons.close : Icons.arrow_back), onPressed: () => step == 0 ? Navigator.pop(context) : setState(() => step--)),
        title: Text('Step ${step + 1} of 4', style: const TextStyle(fontSize: 14, color: g500, fontWeight: FontWeight.w500)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(4), child: LinearProgressIndicator(value: (step + 1) / 4, minHeight: 4, color: orange, backgroundColor: g200)),
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 16), children: [
            Text(titles[step], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            if (step == 0) ..._step0(),
            if (step == 1) ..._step1(),
            if (step == 2) ..._step2(),
            if (step == 3) ..._step3(),
          ])),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (step < 3) FilledButton(onPressed: canNext ? () => setState(() => step++) : null, child: Text(step == 2 && photos.isEmpty ? 'Skip photos for now' : 'Continue')),
              if (step == 3) ...[
                FilledButton.icon(onPressed: vname.text.trim().isEmpty ? null : () => finish(Vouch.requested), icon: const Icon(Icons.send), label: const Text('Send request (demo)')),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: () => finish(Vouch.none), child: const Text('Skip, save as self-reported')),
              ],
              if (step == 0 && !canNext) const Padding(padding: EdgeInsets.only(top: 6), child: Text('Add a project name to continue', style: TextStyle(color: g500, fontSize: 12))),
              if (step == 1 && !canNext) const Padding(padding: EdgeInsets.only(top: 6), child: Text('Pick at least one task to continue', style: TextStyle(color: g500, fontSize: 12))),
            ]),
          ),
        ]),
      ),
    );
  }

  List<Widget> _step0() => [
        const Text('Trade', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final t in trades) Pill('${t.emoji}  ${t.name}', on: trade == t, onTap: () => setState(() { trade = t; tasks.clear(); }))]),
        const SizedBox(height: 18),
        const Text('Your role', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final r in roles) Pill(r, on: role == r, onTap: () => setState(() => role = r))]),
        const SizedBox(height: 18),
        const Text('Project name', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(controller: project, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'e.g. Maple Street apartments')),
        const SizedBox(height: 14),
        TextField(controller: company, decoration: const InputDecoration(hintText: 'Company (optional)')),
        const SizedBox(height: 18),
        const Text('Kind of project', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final k in projectTypes) Pill(k, on: kind == k, onTap: () => setState(() => kind = k))]),
        const SizedBox(height: 18),
        const Text('Started', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final y in years.take(7)) Pill(y, on: start == y, onTap: () => setState(() => start = y))]),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('I still work here'), value: current, activeColor: slate, onChanged: (v) => setState(() => current = v)),
        if (!current) Wrap(spacing: 8, runSpacing: 8, children: [for (final y in years.take(7)) Pill('Ended $y', on: end == y, onTap: () => setState(() => end = y))]),
      ];

  List<Widget> _step1() => [
        Text('Tap everything you did as ${role.toLowerCase()} ${trade.name.toLowerCase()}. Your own words are fine too.', style: const TextStyle(color: g600, height: 1.4)),
        const SizedBox(height: 12),
        for (final t in trade.tasks)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: tasks.contains(t.label) ? slate : g200), color: tasks.contains(t.label) ? const Color(0xFFEFF4F9) : Colors.white),
            child: CheckboxListTile(
              value: tasks.contains(t.label), activeColor: slate, controlAffinity: ListTileControlAffinity.leading,
              title: Text(t.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              onChanged: (v) => setState(() => v == true ? tasks.add(t.label) : tasks.remove(t.label)),
            ),
          ),
        for (final t in tasks.where((t) => !trade.tasks.any((d) => d.label == t)))
          Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: slate), color: const Color(0xFFEFF4F9)), child: ListTile(title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)), trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => tasks.remove(t))))),
        const SizedBox(height: 4),
        Row(children: [
          Expanded(child: TextField(controller: custom, decoration: const InputDecoration(hintText: 'Something else you did'))),
          const SizedBox(width: 8),
          IconButton.filled(style: IconButton.styleFrom(backgroundColor: slate), onPressed: () { final v = custom.text.trim(); if (v.isNotEmpty) { setState(() { tasks.add(v); custom.clear(); }); } }, icon: const Icon(Icons.add)),
        ]),
        const SizedBox(height: 8),
        Text('${tasks.length} selected', style: const TextStyle(color: g500, fontSize: 13)),
      ];

  List<Widget> _step2() => [
        const Text('A photo of the finished work beats a paragraph. Skip faces and anything with a client address.', style: TextStyle(color: g600, height: 1.4)),
        const SizedBox(height: 14),
        Wrap(spacing: 10, runSpacing: 10, children: [
          for (final p in photos) Stack(children: [
            PhotoTile(p, size: 100, onTap: () => _tag(p)),
            Positioned(right: 4, top: 4, child: InkWell(onTap: () => setState(() => photos.remove(p)), child: const CircleAvatar(radius: 11, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 14, color: Colors.white)))),
            if (p.task.isNotEmpty) Positioned(left: 0, right: 0, bottom: 0, child: Container(padding: const EdgeInsets.all(3), color: Colors.black54, child: Text(p.task, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 10)))),
          ]),
          InkWell(onTap: pick, child: Container(width: 100, height: 100, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: g300), color: g50), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, color: slate), SizedBox(height: 4), Text('Add photo', style: TextStyle(fontSize: 12, color: slate, fontWeight: FontWeight.w600))]))),
        ]),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: () => setState(() => photos.add(Photo(tint: [slate, amber, green][photos.length % 3], icon: Icons.handyman))), icon: const Icon(Icons.image_outlined), label: const Text('Use a sample photo (demo)')),
        const SizedBox(height: 10),
        if (photos.isNotEmpty) const Text('Tap a photo to say which task it shows.', style: TextStyle(color: g500, fontSize: 13)),
      ];

  void _tag(Photo p) => showModalBottomSheet(
        context: context, showDragHandle: true,
        builder: (c) => Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('This photo shows...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final t in tasks) Pill(t, on: p.task == t, onTap: () { setState(() => p.task = t); Navigator.pop(c); })]),
        ])),
      );

  List<Widget> _step3() => [
        const Text('Someone who saw the work can confirm it. They get a text with one button. Their name shows next to the job.', style: TextStyle(color: g600, height: 1.4)),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final r in vouchRoles) Pill(r, on: vrole == r, onTap: () => setState(() => vrole = r))]),
        const SizedBox(height: 14),
        TextField(controller: vname, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'Their first name and initial')),
        const SizedBox(height: 14),
        TextField(keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Their phone number (not used in demo)')),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: g100, borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Text they would get', style: TextStyle(fontSize: 12, color: g500, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Hi ${vname.text.trim().isEmpty ? '[name]' : vname.text.trim()}, Marcus says he worked with you on "${project.text.trim()}" as a ${role.toLowerCase()} ${trade.name.toLowerCase()}. Did he do these ${tasks.length} things? Tap to review and confirm: example.link/c/abc123', style: const TextStyle(height: 1.4)),
          ]),
        ),
        const SizedBox(height: 8),
        const Text('Demo only. This message is not sent.', style: TextStyle(color: g500, fontSize: 12)),
      ];
}
