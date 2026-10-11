import pandas as pd


def build_def(family: str, archetype: str, rarity: str, effect_string: str) -> str:
    name = f"{family}_{archetype}_{rarity}"
    print(name.upper())
    return (
        f"\n## {effect_string}\n"
        f"static var {name.upper()} := PickTemplates.new(\n"
        f"\t\"{name.lower()}\",\n"
        f"\tFamilies.{family.upper()},\n"
        f"\tArchetypes.{archetype.upper()},\n"
        f"\tRarities.{rarity.upper()},\n"
        f"\t\"{effect_string}\"\n"
        f")\n"
    )


if __name__ == "__main__":
    df = pd.read_csv(r".\pick_template_template.csv")
    print(df)
    
    definitions = []
    
    for idx, row in df.iterrows():
        for column in df.columns[2:]:
            definitions.append(
                build_def(
                    row["family"],
                    row["archetype"],
                    column,
                    row[column]
                )            
            )
    
    print(definitions[0])
    print(definitions[-1])
    
    with open(r"./monger_monged.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(definitions))