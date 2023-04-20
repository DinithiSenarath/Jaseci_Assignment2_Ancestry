import {*} with "./graph.jac";

walker create_familytree {
    // creates a familytree from a json file
    has data_file = "familytree.json";
    has family_members = [];

    root {
        families = file.load_json(data_file)["families"];
        for family in families {
            spawn here ++> node::family_root(
                id = family["uid"],
                family_name = family["family_name"]
            );
        }
        take-->node::family_root;
    }

    family_root {
        family_id = here.id;
        members = file.load_json(data_file)["members"];
        for member in members {
            if (member["family_id"] != family_id): continue;
            family_member = spawn here +[member]+> node::person(
                id = member["uid"],
                family_id = member["family_id"],
                name = member["name"],
                date_of_birth = member["date_of_birth"],
                profession = member["profession"],
                gender = member["gender"],
                deceased = member["deceased"],
                parents = member["parents"],
                children = member["children"],
                spouse = member["spouse"],
                sport=member["sport"],
                vehicle = member["vehicle"],
                music = member["music"]
            );
            family_members.list::append(family_member);  
            
        }
        
    }

    with exit {
        for member_1 in family_members {
            for member_2 in family_members {
                if (member_1.id == member_2.id): continue;
                if (member_1.spouse == member_2.id and member_2.spouse == member_1.id) {
                    member_1 +[married]+> member_2;
                }
                if (member_1.id in member_2.children): member_1 +[child]+> member_2;
            }
        }
    }
}

walker find_coming_birthday {
    // returns the upcoming birthdays of the family
    has max_return = 5;
    has anchor birthday_order = [];

    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        if (!here.deceased) {
            here::get_days_to_birthday;
            here::get_age;
            birthday_order.l::append([here.days_to_birthday, here.age, here.name]);
        }
    }
    with exit {
        birthday_order = std.sort_by_col(birthday_order, 0);
        birthday_order = birthday_order[0:max_return];
        std.out(birthday_order);
        report birthday_order;
    }
}
walker assignment {
    has anchor sport_list = [];
    has anchor sports;
    
    has anchor vehicle_list = [];
    has anchor vehicles;
    
    has anchor music_list = [];
    has anchor musics;


    root: take-->node::family_root;
    family_root: take-->node::person;
    
    person{
        
        sports = here.sports;
        if sports:
            for sport in sports:
                if sport in sport_list:
                    continue;
                else:
                    sport_list.list::append(sport);
    }
    
    person{
        
        vehicles = here.vehicles;
        if vehicles:
            for vehicle in vehicles:
                if vehicle in vehicle_list:
                    continue;
                else:
                    vehicle_list.list::append(vehicle);
    }
    
    person{
        
        musics = here.musics;
        if musics:
            for music in musics:
                if music in music_list:
                    continue;
                else:
                    music_list.list::append(music);
    }
    with exit {
        report sport_list;
        report vehicle_list;
        report music_list;
        }

}



